import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/search.dart';
import 'package:ybb/widgets/header.dart';
import 'package:ybb/widgets/post.dart';
import 'package:ybb/widgets/progress.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Post> posts;
  List<String> followingList = [];

  var refreshkey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  // Future<void> getPosts() async {
  //   getFollowing().then((value) => getTimeline());
  // }

  // Future<void> getTimeline() async {
  //   List<Post> userPosts = [];
  //   followingList.forEach((element) async {
  //     QuerySnapshot snapshot = await postsRef
  //         .doc(element)
  //         .collection('userPosts')
  //         .orderBy('timestamp', descending: true)
  //         .get();

  //     userPosts
  //         .addAll(snapshot.docs.map((doc) => Post.fromDocument(doc)).toList());

  //     setState(() {
  //       this.posts = userPosts;
  //     });
  //   });
  // }

  Future<void> getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  buildProgressTimeline() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
        ),
        circularProgress(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Text("Fecthing data..."),
      ],
    );
  }

  buildTimeline() {
    if (posts == null) {
      return buildProgressTimeline();
    } else if (posts.isEmpty) {
      return buildNoFeed();
    } else {
      // return ListView(
      //   shrinkWrap: true,
      //   children: posts,
      // );
      // return ListView.builder(
      //   physics: AlwaysScrollableScrollPhysics(),
      //   shrinkWrap: true,
      //   itemCount: posts?.length,
      //   itemBuilder: (context, item) => posts[item],
      // );
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: posts,
        ),
      );
    }
  }

  Future<Null> refreshTimeline() async {
    refreshkey.currentState?.show(atTop: true);

    setState(() {
      posts = [];
    });

    await getTimeline();
    await buildTimeline();
  }

  buildNoFeed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
          ),
          SvgPicture.asset(
            'assets/images/no_notif.svg',
            height: 170,
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            "Follow others to see what they're up to.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });

        return Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      color: Theme.of(context).primaryColor,
                      size: 30.0,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "People you might know",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(children: userResults),
              //buildNoFeed(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        isAppTitle: true,
        currentUser: currentUser,
        removeBackButton: true,
      ),
      resizeToAvoidBottomPadding: false,
      body: RefreshIndicator(
        key: refreshkey,
        onRefresh: refreshTimeline,
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              //buildUsersToFollow(),
              buildTimeline(),
            ],
          ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}
