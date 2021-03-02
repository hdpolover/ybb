import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uuid/uuid.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/comments.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/post_in_detail.dart';
import 'package:ybb/widgets/shimmers/comment_shimmer_layout.dart';
import 'package:ybb/widgets/shimmers/single_post_shimmer_layout.dart';

class PostDetail extends StatefulWidget {
  final String userId;
  final String postId;

  PostDetail({this.userId, this.postId});

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController commentController = TextEditingController();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  List<Comment> comments = [];

  String commentId = Uuid().v4();

  bool isCommentValid;
  FocusNode focusNode;

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

    bool isNotPostOwner = widget.userId != currentUser.id;
    if (isNotPostOwner) {
      activityFeedRef.doc(widget.userId).collection('feedItems').add(
        {
          "type": "comment",
          "commentData": commentController.text,
          "timestamp": DateTime.now(),
          "postId": widget.postId,
          "userId": currentUser.id,
          "mediaUrl": "",
        },
      );
    }

    SnackBar snackBar = SnackBar(content: Text("Comment added"));
    _scaffoldKey.currentState.showSnackBar(snackBar);

    commentController.clear();

    setState(() {
      commentId = Uuid().v4();
    });
  }

  buildCommentField() {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: TextFormField(
          focusNode: focusNode,
          controller: commentController,
          decoration: InputDecoration(
            errorText: isCommentValid ? null : "Comment cannot be empty",
            labelText: "Write a comment...",
            hintStyle: TextStyle(
              fontFamily: fontName,
            ),
          ),
        ),
        leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl)),
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

  buildCommentLayout() {
    return StreamBuilder(
        stream: commentsRef
            .doc(widget.postId)
            .collection('comments')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CommentShimmer();
          }

          comments = [];
          snapshot.data.documents.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });

          return comments.length == 0
              ? buildNoComment()
              : Column(
                  children: comments,
                );
        });
  }

  buildPostLayout() {
    return FutureBuilder(
      future: postsRef
          .doc(widget.userId)
          .collection('userPosts')
          .doc(widget.postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SinglePostShimmer();
        }

        PostInDetail post = PostInDetail.fromDocument(snapshot.data);

        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Container(
            child: post,
          ),
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: defaultAppBar(context, titleText: "Detail Post"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  buildPostLayout(),
                  buildCommentLayout(),
                ],
              ),
            ),
          ),
          buildCommentField(),
        ],
      ),
    );
  }
}
