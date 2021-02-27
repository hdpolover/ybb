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

  Column buildCountColumn(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  GestureDetector buildButton({String text, Function function}) {
    return GestureDetector(
      onTap: function,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: isFollowing && currentUserId != widget.profileId
              ? Colors.white
              : null,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  color: isFollowing && currentUserId != widget.profileId
                      ? Colors.blue
                      : Colors.white,
                  fontSize: 12),
            ),
          ),
        ),
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.all(3),
    //   child: Container(
    //     child: FlatButton(
    //       onPressed: function,
    //       child: Container(
    //         width: MediaQuery.of(context).size.width * 0.365,
    //         height: 40.0,
    //         child: Text(
    //           text,
    //           style: TextStyle(
    //             color: isFollowing ? Colors.black : Colors.white,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //         alignment: Alignment.center,
    //         decoration: BoxDecoration(
    //           color: isFollowing ? Colors.white : Colors.blue,
    //           border: Border.all(
    //             color: isFollowing ? Colors.grey : Colors.blue,
    //           ),
    //           borderRadius: BorderRadius.circular(8.0),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "EDIT PROFILE",
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        text: "UNFOLLOW",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "FOLLOW",
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
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bio",
                    style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      user.bio,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          letterSpacing: .7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Interests",
                    style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      user.interests,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          letterSpacing: .7),
                    ),
                  ),
                ],
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

        return Row(
          children: <Widget>[
            CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.07,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.displayName.length > 20
                      ? user.displayName.substring(0, 21) + "..."
                      : user.displayName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Text(
                  "@" + user.username,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Text(
                  user.occupation,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            )
          ],
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
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: posts,
          ),
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
        FlatButton(
          textColor: Colors.grey,
          height: 50.0,
          onPressed: () => showProfileMenu("dashboard"),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.dashboard,
                  color: profileMenu == "dashboard"
                      ? Colors.white
                      : Colors.white60,
                ),
              ),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: profileMenu == "dashboard"
                      ? Colors.white
                      : Colors.white60,
                ),
              )
            ],
          ),
        ),
        FlatButton(
          textColor: Colors.grey,
          height: 50.0,
          onPressed: () => showProfileMenu("posts"),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.archive,
                  color: profileMenu == "posts" ? Colors.white : Colors.white60,
                ),
              ),
              Text(
                'Posts',
                style: TextStyle(
                  color: profileMenu == "posts" ? Colors.white : Colors.white60,
                ),
              )
            ],
          ),
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
      backgroundColor: Color(0xffF8F8FA),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: MediaQuery.of(context).size.height * 0.12),
              child: Column(
                children: <Widget>[
                  buildProfileHeader(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      buildCountColumn("followers", followerCount),
                      buildCountColumn("following", followingCount),
                      buildProfileButton(),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  buildProfileMenu(),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.38),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                  )),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 10,
                          top: MediaQuery.of(context).size.height * 0.02),
                      child: buildProfilePosts(),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     elevation: 0,
    //     automaticallyImplyLeading: false,
    //     title: Text(
    //       "Profile",
    //       style: TextStyle(
    //         color: Colors.black,
    //         fontFamily: "Montserrat",
    //         fontSize: 20.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     actions: <Widget>[
    //       currentUserId == widget.profileId
    //           ? IconButton(
    //               icon: Icon(
    //                 Icons.settings,
    //                 color: Colors.black,
    //               ),
    //               onPressed: () => Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                   builder: (context) => ProfileSettings(
    //                     appName: "YBB",
    //                     version: "1.0.0",
    //                   ),
    //                 ),
    //               ),
    //             )
    //           : Text(""),
    //     ],
    //     backgroundColor: Colors.white,
    //   ),
    //   body: RefreshIndicator(
    //     key: refreshkey,
    //     onRefresh: refreshProfile,
    //     child: ListView(
    //       children: <Widget>[
    //         buildProfileHeader(),
    //         Divider(),
    //         buildProfileMenu(),
    //         Divider(),
    //         buildProfilePosts(),
    //       ],
    //     ),
    //   ),
    // );
  }
}
