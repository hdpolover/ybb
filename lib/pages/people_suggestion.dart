import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/search.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/comment_shimmer_layout.dart';

class PeopleSuggestion extends StatefulWidget {
  @override
  _PeopleSuggestionState createState() => _PeopleSuggestionState();
}

class _PeopleSuggestionState extends State<PeopleSuggestion> {
  List<String> userIds = [];
  List<UserResult> results = [];
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();

    getFollows();
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

  buildUsersToFollow() {
    return StreamBuilder(
      stream: usersRef
          .orderBy('registerDate', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CommentShimmer();
        }

        List<UserResult> userToFollow = [];
        snapshot.data.documents.forEach(
          (doc) {
            AppUser user = AppUser.fromDocument(doc);
            final bool isFollowingUser = followingList.contains(user.id);
            // remove auth user from recommended list
            if (!isFollowingUser) {
              UserResult userResult = UserResult(user);
              userToFollow.add(userResult);
            }
          },
        );

        return userToFollow.length == 0
            ? buildNoContent()
            : ListView(children: userToFollow);
      },
    );
  }

  getFollows() async {
    getFollowing().then((value) => buildUsersToFollow());
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

  buildPeopleResults() {
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
      appBar: defaultAppBar(context, titleText: "People to Follow"),
      body: buildUsersToFollow(),
    );
  }
}
