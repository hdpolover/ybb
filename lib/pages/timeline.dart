import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/models/article.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/header.dart';
import 'package:ybb/widgets/post.dart';
import 'package:ybb/widgets/shimmers/post_shimmer_layout.dart';

List<String> idFollowing = [];
List<ArticleModel> newsFromTimeline;

class Timeline extends StatefulWidget {
  final AppUser currentUser;

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

  List<Post> shownPosts = [];
  int lastIndex = 0;
  int postLimit = postTimelineLimit;
  bool hasMore = true;
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();

  //pagination
  //List<DocumentSnapshot> products = []; // stores fetched products
  // track if products fetching
  // flag for more products available or not
  //int documentLimit = 3; // documents to be fetched per request
  //DocumentSnapshot
  //lastDocument; // flag for last document from where next 10 records to be fetched

  @override
  void initState() {
    super.initState();

    getNews();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        getMore();
      }
    });

    getRawPosts();
  }

  getNews() async {
    NewsData newsData = new NewsData();

    newsFromTimeline = [];

    await newsData.getArticles();

    newsFromTimeline = newsData.articles;
  }

  getRawPosts() async {
    await getIdFollowing();

    List<Post> rawPosts = [];

    for (int i = 0; i < followingList.length; i++) {
      QuerySnapshot snapshot = await postsRef
          .doc(followingList[i])
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .get();

      rawPosts
          .addAll(snapshot.docs.map((doc) => Post.fromDocument(doc)).toList());
    }

    Comparator<Post> sortByTimePosted = (a, b) => a.postId.compareTo(b.postId);
    rawPosts.sort(sortByTimePosted);

    setState(() {
      posts = rawPosts.reversed.toList();
    });

    getMore();
  }

  getMore() async {
    if (!hasMore) {
      return;
    }

    if (isLoading) {
      return;
    }

    print("post count: " + posts.length.toString());

    setState(() {
      isLoading = true;
    });

    List<Post> a = [];

    if (lastIndex == 0) {
      for (int i = 0; i < postLimit; i++) {
        a.add(posts[i]);
      }
      print("first");
    } else if (lastIndex >= posts.length) {
      for (int i = 0; i < posts.length; i++) {
        a.add(posts[i]);
      }
      print("out");
    } else {
      for (int i = 0; i < lastIndex; i++) {
        a.add(posts[i]);
      }
      print("usual");
    }

    setState(() {
      shownPosts = a;
    });

    if (lastIndex >= posts.length) {
      hasMore = false;
      print("has no more");
    }

    lastIndex += postLimit;

    // Timer(
    //   Duration(seconds: 1),
    //   () {
    //     setState(() {
    //       isLoading = false;
    //     });
    //   },
    // );

    setState(() {
      isLoading = false;
    });

    print("shownpost count after added: " + shownPosts.length.toString());
    print('last index: ' + lastIndex.toString());
  }

  // getTimeline() async {
  //   if (!hasMore) {
  //     return;
  //   }
  //   if (isLoading) {
  //     return;
  //   }
  //   setState(() {
  //     isLoading = true;
  //   });

  //   QuerySnapshot querySnapshot;
  //   if (lastDocument == null) {
  //     querySnapshot = await timelineRef
  //         .doc(widget.currentUser.id)
  //         .collection('timelinePosts')
  //         .orderBy('timestamp', descending: true)
  //         .limit(documentLimit)
  //         .get();
  //   } else {
  //     querySnapshot = await timelineRef
  //         .doc(widget.currentUser.id)
  //         .collection('timelinePosts')
  //         .orderBy('timestamp', descending: true)
  //         .startAfterDocument(lastDocument)
  //         .limit(documentLimit)
  //         .get();
  //   }

  //   if (querySnapshot.docs.length < documentLimit) {
  //     hasMore = false;
  //   }

  //   try {
  //     lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }

  //   products.addAll(querySnapshot.docs);

  //   List<Post> posts = products.map((doc) => Post.fromDocument(doc)).toList();
  //   setState(() {
  //     this.posts = posts;
  //     isLoading = false;
  //   });
  // }

  getIdFollowing() async {
    // NewsData newsData = new NewsData();

    // await newsData.getFollowing();
    // setState(() {
    //   idFollowing = newsData.followingList;
    //   followingList = newsData.followingList;
    // });
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();

    followingList = snapshot.docs.map((doc) => doc.id).toList();
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
      // return SingleChildScrollView(
      //   child: Padding(
      //     padding: const EdgeInsets.all(15),
      //     child: Column(
      //       children: posts,
      //     ),
      //   ),
      // );
      return Column(
        children: [
          Expanded(
            child: posts.length == 0
                ? Center(
                    child: buildNoFeed(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 0),
                    controller: _scrollController,
                    itemCount: shownPosts.length,
                    itemBuilder: (context, index) {
                      return shownPosts[index];
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
      // return Column(
      //   children: [
      //     Expanded(
      //       child: products.length == 0
      //           ? Center(
      //               child: buildNoFeed(),
      //             )
      //           : ListView.builder(
      //               padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 0),
      //               controller: _scrollController,
      //               itemCount: products.length,
      //               itemBuilder: (context, index) {
      //                 return posts[index];
      //               },
      //             ),
      //     ),
      //     isLoading
      //         ? Container(
      //             width: MediaQuery.of(context).size.width,
      //             padding: EdgeInsets.all(5),
      //             color: Colors.blue,
      //             child: Text(
      //               'Loading',
      //               textAlign: TextAlign.center,
      //               style: TextStyle(
      //                 color: Colors.white,
      //                 fontFamily: fontName,
      //                 letterSpacing: 1,
      //               ),
      //             ),
      //           )
      //         : Container()
      //   ],
      // );
    }
  }

  Future<Null> refreshTimeline() async {
    refreshkey.currentState?.show(atTop: true);

    setState(() {
      shownPosts = [];
      posts = [];
      lastIndex = 0;
      postLimit = postTimelineLimit;
      // products = [];
      // lastDocument = null;
      hasMore = true;
      isLoading = false;
    });

    //await getTimeline();
    await getRawPosts();
    await getMore();
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
