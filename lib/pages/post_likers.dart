import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/search.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/comment_shimmer_layout.dart';

class PostLikers extends StatefulWidget {
  final List<String> likerIds;
  final String postId;

  PostLikers({@required this.likerIds, @required this.postId});

  @override
  _PostLikersState createState() => _PostLikersState();
}

class _PostLikersState extends State<PostLikers> {
  List<UserResult> results = [];

  buildPostLikers() {
    return StreamBuilder(
      stream: usersRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CommentShimmer();
        }

        List<UserResult> userToFollow = [];
        snapshot.data.documents.forEach(
          (doc) {
            User user = User.fromDocument(doc);
            final bool isLiker = widget.likerIds.contains(user.id);
            // remove auth user from recommended list
            if (isLiker) {
              UserResult userResult = UserResult(user);
              userToFollow.add(userResult);
            }
          },
        );

        return Column(children: userToFollow);
      },
    );
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

  buildLikerResults() {
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
      appBar: defaultAppBar(context, titleText: "Post Likes"),
      body: buildPostLikers(),
    );
  }
}
