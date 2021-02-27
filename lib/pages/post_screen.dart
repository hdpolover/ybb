import 'package:flutter/material.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/post.dart';
import 'package:ybb/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        Post post = Post.fromDocument(snapshot.data);

        return Center(
          child: Scaffold(
            appBar: defaultAppBar(context, titleText: "Detail Post"),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
