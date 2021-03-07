import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/edit_profile.dart';
import 'package:ybb/pages/follows.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/settings.dart';
import 'package:ybb/pages/upload_post.dart';
import 'package:ybb/widgets/post.dart';
import 'package:ybb/widgets/shimmers/profile_dashboard_shimmer_layout.dart';
import 'package:ybb/widgets/shimmers/profile_header_shimmer_layout.dart';

class Profile extends StatefulWidget {
  final String profileId;
  final bool isFromOutside;

  Profile({@required this.profileId, @required this.isFromOutside});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with AutomaticKeepAliveClientMixin<Profile> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  final String currentUserId = currentUser?.id;
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  List<ActionChip> interestChips;
  List<String> interestStringList;

  bool removeBackButton;
  bool removeSettingButton;

  String profileMenu = "dashboard";

  @override
  void initState() {
    super.initState();

    manageAppbar();

    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  manageAppbar() {
    if (currentUserId == widget.profileId && !widget.isFromOutside) {
      setState(() {
        removeBackButton = true;
        removeSettingButton = false;
      });
    } else if (currentUserId == widget.profileId && widget.isFromOutside) {
      setState(() {
        removeBackButton = false;
        removeSettingButton = false;
      });
    } else {
      setState(() {
        removeBackButton = false;
        removeSettingButton = true;
      });
    }
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
        .limit(10)
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
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: fontName,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: fontName,
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

  Container buildButton({String text, Function function}) {
    return Container(
      child: ConnectivityWidgetWrapper(
        stacked: false,
        offlineWidget: GestureDetector(
          onTap: null,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              color: isFollowing && currentUserId != widget.profileId
                  ? Colors.white38
                  : null,
              border: Border.all(
                color: Colors.grey,
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
                        ? Colors.grey
                        : Colors.grey,
                    fontSize: 12,
                    fontFamily: fontName,
                  ),
                ),
              ),
            ),
          ),
        ),
        child: GestureDetector(
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
                    fontSize: 12,
                    fontFamily: fontName,
                  ),
                ),
              ),
            ),
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
      "userId": currentUserId,
      "timestamp": DateTime.now(),
      "commentData": "",
      "postId": "",
      "feedId": currentUserId,
    });
  }

  buildProfileDashboard() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ProfileDashboardShimmer();
        }

        AppUser user = AppUser.fromDocument(snapshot.data);

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      user.displayName,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        letterSpacing: .7,
                        fontFamily: fontName,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      user.occupation,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        letterSpacing: .7,
                        fontFamily: fontName,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[700],
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Joined in ",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            letterSpacing: .7,
                            fontFamily: fontName,
                          ),
                        ),
                        Text(
                          convertDateTime(user.registerDate),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            letterSpacing: .7,
                            fontFamily: fontName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  user.showContacts
                      ? Column(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.phone,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    user.phoneNumber,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                      letterSpacing: .7,
                                      fontFamily: fontName,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                      letterSpacing: .7,
                                      fontFamily: fontName,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.instagram,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "@" + user.instagram,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                      letterSpacing: .7,
                                      fontFamily: fontName,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.facebookSquare,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "@" + user.facebook,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                      letterSpacing: .7,
                                      fontFamily: fontName,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.globe,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    user.website,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                      letterSpacing: .7,
                                      fontFamily: fontName,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container(),
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
                    "Bio",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: fontName,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      user.bio,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        letterSpacing: .7,
                        fontFamily: fontName,
                      ),
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
                      color: Colors.blue,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: fontName,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      user.interests,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        letterSpacing: .7,
                        fontFamily: fontName,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.4),
          ],
        );
      },
    );
  }

  String convertDateTime(DateTime postedDate) {
    return DateFormat.yMMMd().format(postedDate);
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ProfileHeaderShimmer();
        }

        AppUser user = AppUser.fromDocument(snapshot.data);

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
                      ? user.displayName.substring(0, 19) + "..."
                      : user.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontName,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Text(
                  "@" + user.username,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    fontFamily: fontName,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Text(
                  user.occupation.length > 34
                      ? user.occupation.substring(0, 33) + "..."
                      : user.occupation,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    fontFamily: fontName,
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          SvgPicture.asset(
            'assets/images/no_post.svg',
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Text(
              "It seems like you have no posts yet. Make one now.",
              style: TextStyle(
                color: Colors.black,
                fontFamily: fontName,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
              bottom: MediaQuery.of(context).size.height * 0.02,
            ),
            child: TextButton.icon(
              icon: Icon(Icons.edit),
              label: Text(
                "Create a post",
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: fontName,
                ),
              ),
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
      heightFactor: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          SvgPicture.asset(
            'assets/images/no_post.svg',
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
              bottom: MediaQuery.of(context).size.height * 0.02,
            ),
            child: Text(
              "This user doesn't seem to have any posts.",
              style: TextStyle(
                color: Colors.black,
                fontFamily: fontName,
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return ProfileDashboardShimmer();
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
          padding: const EdgeInsets.all(15.0),
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
          onPressed: () => showProfileMenu("dashboard"),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
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
                  fontFamily: fontName,
                  letterSpacing: .7,
                ),
              )
            ],
          ),
        ),
        FlatButton(
          textColor: Colors.grey,
          onPressed: () => showProfileMenu("posts"),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                child: Icon(
                  Icons.archive,
                  color: profileMenu == "posts" ? Colors.white : Colors.white60,
                ),
              ),
              Text(
                postCount.toString() + ' Posts',
                style: TextStyle(
                  color: profileMenu == "posts" ? Colors.white : Colors.white60,
                  fontFamily: fontName,
                  letterSpacing: .7,
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

    setState(() {
      posts = [];
    });

    await getFollowers();
    await getFollowing();
    await getProfilePosts();
    await checkIfFollowing();

    await buildProfileHeader();
    await buildProfilePosts();
  }

  bool get wantKeepAlive => true;

  buildAppbar() {
    return AppBar(
      automaticallyImplyLeading: true,
      elevation: 0,
      leading: removeBackButton
          ? Text('')
          : IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
      actions: <Widget>[
        removeSettingButton
            ? Text('')
            : ConnectivityWidgetWrapper(
                stacked: false,
                offlineWidget: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white38,
                  ),
                  onPressed: null,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSettings(),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: buildAppbar(),
      body: LiquidPullToRefresh(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.blue,
        animSpeedFactor: 2.5,
        backgroundColor: Colors.white,
        showChildOpacityTransition: false,
        key: refreshkey,
        onRefresh: refreshProfile,
        child: ConnectivityScreenWrapper(
          child: SingleChildScrollView(
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Container(
                  color: Theme.of(context).primaryColor,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1,
                        right: MediaQuery.of(context).size.height * 0.05,
                        top: MediaQuery.of(context).size.height * 0.01),
                    child: Column(
                      children: <Widget>[
                        buildProfileHeader(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Follows(
                                    type: "followers",
                                    userId: widget.profileId,
                                  ),
                                ),
                              ),
                              child:
                                  buildCountColumn("Followers", followerCount),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Follows(
                                    type: "followings",
                                    userId: widget.profileId,
                                  ),
                                ),
                              ),
                              child: buildCountColumn(
                                  "Followings", followingCount),
                            ),
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
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.32),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(
                              MediaQuery.of(context).size.width * 0.1),
                          topLeft: Radius.circular(
                              MediaQuery.of(context).size.width * 0.1),
                        )),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.05),
                            child: buildProfilePosts(),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
