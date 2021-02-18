import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

    getPosts();
  }

  Future<void> getPosts() async {
    getFollowing().then((value) => getTimeline());
  }

  Future<void> getTimeline() async {
    List<Post> userPosts = [];
    followingList.forEach((element) async {
      QuerySnapshot snapshot = await postsRef
          .doc(element)
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .get();

      userPosts
          .addAll(snapshot.docs.map((doc) => Post.fromDocument(doc)).toList());

      setState(() {
        this.posts = userPosts;
      });
    });
  }

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
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  Future<Null> refreshTimeline() async {
    refreshkey.currentState?.show(atTop: true);

    posts = [];

    await getPosts();
    await buildTimeline();
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
          color: Theme.of(context).accentColor.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      "Users to Follow",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(children: userResults),
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
      body: RefreshIndicator(
        key: refreshkey,
        onRefresh: refreshTimeline,
        child: buildTimeline(),
      ),
    );
  }

  bool get wantKeepAlive => true;
}
