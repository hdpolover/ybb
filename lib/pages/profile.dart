import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/edit_profile.dart';
import 'package:ybb/pages/follows.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/settings.dart';
import 'package:ybb/pages/upload_post.dart';
import 'package:ybb/widgets/post.dart';
import 'package:ybb/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId, username;

  Profile({this.profileId, this.username});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with AutomaticKeepAliveClientMixin<Profile> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  final String currentUserId = currentUser?.id;
  String postOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  List<ActionChip> interestChips;
  List<String> interestStringList;

  String profileMenu = "dashboard";

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();

    List<String> ids = snapshot.docs.map((doc) => doc.id).toList();

    int fixCount = 0;
    if (ids.contains(widget.profileId)) {
      fixCount = ids.length - 1;
    } else {
      fixCount = ids.length;
    }

    setState(() {
      followerCount = fixCount;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();

    List<String> ids = snapshot.docs.map((doc) => doc.id).toList();

    int fixCount = 0;
    if (ids.contains(widget.profileId)) {
      fixCount = ids.length - 1;
    } else {
      fixCount = ids.length;
    }

    setState(() {
      followingCount = fixCount;
    });
  }

  Future<Null> getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Container buildCountColumn(String label, int count) {
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Follows(
                type: label,
                userId: widget.profileId,
              ),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              count.toString(),
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.only(top: 4.0),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 5.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: double.infinity,
          height: 35.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "displayName": currentUser.displayName,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
      "commentData": "",
      "mediaUrl": "",
      "postId": "",
    });
  }

  buildInterestChips(String text) {
    List<String> list = text.split(",");
    print(list);

    ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: Icon(Icons.list),
              trailing: Text(
                "GFG",
                style: TextStyle(color: Colors.green, fontSize: 15),
              ),
              title: Text("List item $index"));
        });
  }

  buildProfileDashboard() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(snapshot.data);

        return Column(
          children: [
            Card(
              elevation: 0.5,
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bio",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    Text(user.bio),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 0.5,
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Interests",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    Text(user.interests),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(snapshot.data);

        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 60.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 30.0, bottom: 5.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            user.displayName,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 30.0, bottom: 5.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            user.username.length > 15
                                ? "@" + user.username.substring(0, 15) + "..."
                                : "@" + user.username,
                          ),
                        ),
                        SizedBox(height: 60),
                        Container(
                          margin: EdgeInsets.only(left: 30.0, bottom: 5.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            user.occupation.length == 0 ? "" : user.occupation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.0),
              buildProfileButton(),
              SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  buildCountColumn("followers", followerCount),
                  buildCountColumn("followings", followingCount),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  buildProfileOwnerNoPost() {
    return Center(
      heightFactor: 1.35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/no_post.svg', height: 150.0),
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Text(
              "It seems like you have no posts yet. Make one now.",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton.icon(
              icon: Icon(Icons.edit),
              label: Text("Create a Post"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPost(
                      currentUser: currentUser,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  buiildOtherProfileNoPost() {
    return Center(
      heightFactor: 1.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/no_post.svg', height: 150.0),
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Text(
              "This user doesn't seem to have any posts.",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }
    if (profileMenu == "dashboard") {
      return buildProfileDashboard();
    } else if (profileMenu == "posts") {
      if (posts.isEmpty) {
        return currentUserId == widget.profileId
            ? buildProfileOwnerNoPost()
            : buiildOtherProfileNoPost();
      } else {
        return Column(
          children: posts,
        );
      }
    }
  }

  showProfileMenu(String option) {
    setState(() {
      this.profileMenu = option;
    });
  }

  buildProfileMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => showProfileMenu("dashboard"),
          icon: Icon(Icons.dashboard),
          color: profileMenu == "dashboard"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          icon: Icon(Icons.portrait_sharp),
          onPressed: () => showProfileMenu("posts"),
          color: profileMenu == "posts"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  Future<Null> refreshProfile() async {
    refreshkey.currentState?.show(atTop: true);

    await getFollowers();
    await getFollowing();
    await checkIfFollowing();
    await buildProfileHeader();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Montserrat",
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          currentUserId == widget.profileId
              ? IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileSettings(
                        appName: "YBB",
                        version: "1.0.0",
                      ),
                    ),
                  ),
                )
              : Text(""),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        key: refreshkey,
        onRefresh: refreshProfile,
        child: ListView(
          children: <Widget>[
            buildProfileHeader(),
            Divider(),
            buildProfileMenu(),
            Divider(),
            buildProfilePosts(),
          ],
        ),
      ),
    );
  }
}
