import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/progress.dart';

// ignore: must_be_immutable
class Follows extends StatefulWidget {
  final String type;
  final String userId;

  Follows({this.type, this.userId});

  @override
  _FollowsState createState() => _FollowsState();
}

class _FollowsState extends State<Follows> {
  List<String> userIds = [];
  List<UserResult> results;

  @override
  void initState() {
    super.initState();

    getFollows(widget.type);
  }

  Future<void> getFollowing() async {
    QuerySnapshot snapshot =
        await followingRef.doc(widget.userId).collection('userFollowing').get();

    setState(() {
      userIds = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> getFollowers() async {
    QuerySnapshot snapshot =
        await followersRef.doc(widget.userId).collection('userFollowers').get();

    setState(() {
      userIds = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> getUsers() async {
    List<UserResult> users = [];
    userIds.forEach((element) async {
      if (element != widget.userId) {
        DocumentSnapshot snapshot = await usersRef.doc(element).get();

        User user = User.fromDocument(snapshot);
        UserResult userResult = UserResult(user);

        users.add(userResult);

        setState(() {
          results = users;
        });
      }
    });
  }

  getFollows(String type) async {
    if (type == "followers") {
      getFollowers().then((value) => getUsers());
    } else if (type == "followings") {
      getFollowing().then((value) => getUsers());
    }
  }

  Container buildNoContent() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_search.svg',
              height: 200.0,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Find people to broaden your network.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildFollowResults() {
    if (results == null) {
      return circularProgress();
    } else {
      return results.length == 0
          ? buildNoContent()
          : ListView(children: results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context,
          titleText:
              widget.type.contains("followers") ? "Followers" : "Followings"),
      body: buildFollowResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
