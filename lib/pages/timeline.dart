import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/header.dart';
import 'package:ybb/widgets/post.dart';
import 'package:ybb/widgets/shimmers/post_shimmer_layout.dart';

List<String> idFollowing = [];

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> followingList = [];
  List<Post> posts;

  var refreshkey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    getIdFollowing();
    getTimeline();
    //getFollowing();
  }

  getIdFollowing() async {
    NewsData newsData = new NewsData();

    await newsData.getFollowing();
    setState(() {
      idFollowing = newsData.followingList;
      followingList = newsData.followingList;
    });
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

  buildTimeline() {
    if (posts == null) {
      return PostShimmer();
    } else if (posts.isEmpty) {
      return PostShimmer();
    } else {
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
      body: LiquidPullToRefresh(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.blue,
        animSpeedFactor: 2.5,
        backgroundColor: Colors.white,
        showChildOpacityTransition: false,
        key: refreshkey,
        onRefresh: refreshTimeline,
        child: ConnectivityScreenWrapper(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                buildTimeline(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}
