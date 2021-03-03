import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/constants.dart';
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

  //pagination
  List<DocumentSnapshot> products = []; // stores fetched products
  bool isLoading = false; // track if products fetching
  bool hasMore = true; // flag for more products available or not
  int documentLimit = 3; // documents to be fetched per request
  DocumentSnapshot
      lastDocument; // flag for last document from where next 10 records to be fetched
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getTimeline();
      }
    });

    getTimeline();

    getIdFollowing();
  }

  getTimeline() async {
    if (!hasMore) {
      print('No More Products');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await timelineRef
          .doc(widget.currentUser.id)
          .collection('timelinePosts')
          .orderBy('timestamp', descending: true)
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await timelineRef
          .doc(widget.currentUser.id)
          .collection('timelinePosts')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get();
    }

    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }

    try {
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }

    products.addAll(querySnapshot.docs);

    List<Post> posts = products.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
      isLoading = false;
    });
  }

  getIdFollowing() async {
    NewsData newsData = new NewsData();

    await newsData.getFollowing();
    setState(() {
      idFollowing = newsData.followingList;
      followingList = newsData.followingList;
    });
  }

  // getTimeline() async {
  //   QuerySnapshot snapshot = await timelineRef
  //       .doc(widget.currentUser.id)
  //       .collection('timelinePosts')
  //       .orderBy('timestamp', descending: true)
  //       .limit(10)
  //       .get();
  //   List<Post> posts =
  //       snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
  //   setState(() {
  //     this.posts = posts;
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
      return Column(
        children: [
          Expanded(
            child: products.length == 0
                ? Center(
                    child: buildNoFeed(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 0),
                    controller: _scrollController,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return posts[index];
                    },
                  ),
          ),
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5),
                  color: Colors.blue,
                  child: Text(
                    'Loading',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: fontName,
                      letterSpacing: 1,
                    ),
                  ),
                )
              : Container()
        ],
      );
    }
  }

  Future<Null> refreshTimeline() async {
    refreshkey.currentState?.show(atTop: true);

    setState(() {
      posts = [];
      products = [];
      lastDocument = null;
      hasMore = true;
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
          child: buildTimeline(),
          // child: SingleChildScrollView(
          //   clipBehavior: Clip.none,
          //   physics: AlwaysScrollableScrollPhysics(),
          //   child: Column(
          //     children: [
          //       buildTimeline(),
          //     ],
          //   ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}
