import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/search.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/comment_shimmer_layout.dart';

// ignore: must_be_immutable
class Follows extends StatefulWidget {
  final String type;
  final String userId;

  Follows({@required this.type, @required this.userId});

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
              'assets/images/no_notif.svg',
              height: MediaQuery.of(context).size.width * 0.4,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Nothing to see here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: fontName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildFollowResults() {
    if (results == null) {
      return CommentShimmer();
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
          titleText: widget.type == ("followers") ? "Followers" : "Followings"),
      body: buildFollowResults(),
    );
  }
}
