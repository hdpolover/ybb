import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  List<Comment> comments = [];

  String commentId = Uuid().v4();

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildComments() {
    return StreamBuilder(
        stream: commentsRef
            .doc(postId)
            .collection('comments')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          comments = [];
          snapshot.data.documents.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });

          return comments.length == 0
              ? buildNoComment()
              : ListView(
                  children: comments,
                );
        });
  }

  buildNoComment() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/no_comment.svg',
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Be the first one to comment.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontName,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }

  addComment() {
    commentsRef.doc(postId).collection("comments").doc(commentId).set({
      "displayName": currentUser.displayName,
      "comment": commentController.text,
      "timestamp": DateTime.now(),
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
      "postId": postId,
      "commentId": commentId,
    });

    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": DateTime.now(),
        "postId": postId,
        "userId": currentUser.id,
        "displayName": currentUser.displayName,
        "userProfileImg": currentUser.photoUrl,
        "mediaUrl": postMediaUrl,
      });
    }
    commentController.clear();

    setState(() {
      commentId = Uuid().v4();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: "Write a comment...",
                hintStyle: TextStyle(
                  fontFamily: fontName,
                ),
              ),
            ),
            leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(currentUser.photoUrl)),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text(
                "POST",
                style: TextStyle(
                  fontFamily: fontName,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String displayName;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  final String postId;
  final String commentId;

  Comment({
    this.displayName,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
    this.postId,
    this.commentId,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      displayName: doc['displayName'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
      commentId: doc['commentId'],
      postId: doc['postId'],
    );
  }

  deleteComment(parentContext) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: commonTextStyle,
      ),
      onPressed: () {
        Navigator.pop(parentContext);
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Delete",
        style: TextStyle(color: Colors.red, fontFamily: fontName),
      ),
      onPressed: () {
        commentsRef
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .get()
            .then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });

        Navigator.pop(parentContext);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Delete comment",
        style: commonTextStyle,
      ),
      content: Text(
        "Are you sure to delete your comment?",
        style: commonTextStyle,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () => userId == currentUser.id ? deleteComment(context) : {},
          onLongPress: () =>
              userId == currentUser.id ? deleteComment(context) : {},
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              text: TextSpan(
                text: displayName + ' ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: fontName,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: comment,
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: fontName,
                    ),
                  ),
                ],
              ),
            ),
          ),
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(avatarUrl),
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            style: TextStyle(
              fontFamily: fontName,
            ),
          ),
        ),
        //Divider(),
      ],
    );
  }
}
