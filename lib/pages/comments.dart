import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ybb/models/commenter.dart';
import 'package:ybb/widgets/shimmers/comment_shimmer_layout.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isCommentValid = true;

  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  List<Comment> comments = [];

  String commentId = Uuid().v4();

  FocusNode focusNode;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
    isCommentValid = true;
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .doc(postId)
          .collection('comments')
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CommentShimmer();
        }

        comments = [];
        snapshot.data.documents.forEach(
          (doc) {
            comments.add(Comment.fromDocument(doc));
          },
        );

        return comments.length == 0
            ? buildNoComment()
            : ListView(
                children: comments,
              );
      },
    );
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
            "Be the first person to comment.",
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
    focusNode.unfocus();

    setState(() {
      commentController.text.trim().isEmpty
          ? isCommentValid = false
          : isCommentValid = true;
    });

    if (!isCommentValid) {
      return;
    }

    commentsRef.doc(widget.postId).collection("comments").doc(commentId).set({
      "comment": commentController.text,
      "timestamp": DateTime.now(),
      "userId": currentUser.id,
      "postId": widget.postId,
      "commentId": commentId,
    });

    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(postOwnerId)
          .collection('feedItems')
          .doc(commentId)
          .set(
        {
          "type": "comment",
          "commentData": commentController.text,
          "timestamp": DateTime.now(),
          "postId": widget.postId,
          "userId": currentUser.id,
          "feedId": commentId,
        },
      );
    }

    SnackBar snackBar =
        SnackBar(backgroundColor: Colors.blue, content: Text("Comment added"));
    _scaffoldKey.currentState.showSnackBar(snackBar);

    commentController.clear();

    setState(() {
      commentId = Uuid().v4();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: defaultAppBar(context, titleText: "Comments"),
      body: ConnectivityScreenWrapper(
        child: Column(
          children: <Widget>[
            Expanded(
              child: buildComments(),
            ),
            ListTile(
              title: TextFormField(
                focusNode: focusNode,
                controller: commentController,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  errorText: isCommentValid ? null : "Comment cannot be empty",
                  labelText: "Write a comment...",
                  hintStyle: TextStyle(
                    fontFamily: fontName,
                  ),
                ),
              ),
              leading: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(currentUser.photoUrl)),
              trailing: ConnectivityWidgetWrapper(
                stacked: false,
                offlineWidget: OutlineButton(
                  onPressed: null,
                  borderSide: BorderSide.none,
                  child: Text(
                    "POST",
                    style: TextStyle(
                      fontFamily: fontName,
                      color: Colors.black45,
                    ),
                  ),
                ),
                child: OutlineButton(
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
            ),
          ],
        ),
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String userId;
  final String comment;
  final Timestamp timestamp;
  final String postId;
  final String commentId;

  Comment({
    this.userId,
    this.comment,
    this.timestamp,
    this.postId,
    this.commentId,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
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

  buildCommenterPhoto(context) {
    return FutureBuilder(
      future: usersRef.doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.white,
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 25,
            ),
          );
        }

        Commenter commenter = Commenter.fromDocument(snapshot.data);

        return GestureDetector(
          onTap: () => showProfile(context, profileId: userId),
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.07,
            backgroundImage: CachedNetworkImageProvider(commenter.photoUrl),
          ),
        );
      },
    );
  }

  buildCommenterName() {
    return FutureBuilder(
      future: usersRef.doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.white,
            child: Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          );
        }

        Commenter commenter = Commenter.fromDocument(snapshot.data);

        return Text(
          commenter.displayName,
          style: TextStyle(
            fontFamily: fontName,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () => userId == currentUser.id ? deleteComment(context) : {},
            onLongPress: () =>
                userId == currentUser.id ? deleteComment(context) : {},
            title: GestureDetector(
              onTap: () => showProfile(context, profileId: userId),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCommenterName(),
                  RichText(
                    text: TextSpan(
                      text: comment,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: fontName,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: buildCommenterPhoto(context),
            subtitle: Text(
              timeago.format(timestamp.toDate()),
              style: TextStyle(
                fontFamily: fontName,
              ),
            ),
          ),
          //Divider(),
        ],
      ),
    );
  }
}
