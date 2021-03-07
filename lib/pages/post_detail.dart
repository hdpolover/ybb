import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uuid/uuid.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/comments.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/post_likers.dart';
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
  String firstUsername = "";

  List<String> likerIds = [];

  @override
  void initState() {
    super.initState();
    likerIds = [];
    focusNode = FocusNode();
    isCommentValid = true;
  }

  @override
  void dispose() {
    focusNode.dispose();

    getUserId();
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

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;

    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  Future<String> getUsername(String str) async {
    DocumentSnapshot doc = await usersRef.doc(str).get();

    return doc['displayName'];
  }

  Future<String> getUserId() async {
    DocumentSnapshot doc = await postsRef
        .doc(widget.userId)
        .collection('userPosts')
        .doc(widget.postId)
        .get();

    PostInDetail post = PostInDetail.fromDocument(doc);
    Map<String, dynamic> i = post.likes;
    String id = "";

    i.entries.forEach((element) {
      if (element.value == true) {
        likerIds.add(element.key);
        id = element.key;
      }
    });

    return getUsername(id);
  }

  showLikers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostLikers(likerIds: likerIds, postId: widget.postId),
      ),
    );
  }

  buildLikeDetailSection() {
    return GestureDetector(
      onTap: () => showLikers(),
      child: Padding(
        padding: EdgeInsets.only(left: 15, bottom: 15),
        child: Row(
          children: [
            //Text("$firstUsername and "),
            FutureBuilder(
              future: getUserId(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("");
                }

                String name = snapshot.data;

                return Text(
                  "$name ",
                  style: TextStyle(
                      fontFamily: fontName, fontWeight: FontWeight.bold),
                );
              },
            ),
            FutureBuilder(
              future: postsRef
                  .doc(widget.userId)
                  .collection('userPosts')
                  .doc(widget.postId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("");
                }

                PostInDetail post = PostInDetail.fromDocument(snapshot.data);
                int count = getLikeCount(post.likes) - 1;

                return count == 0
                    ? Text("liked this post")
                    : Text("and $count others liked this post.",
                        style: TextStyle(
                          fontFamily: fontName,
                        ));
              },
            ),
          ],
        ),
      ),
    );
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
    );
  }

  buildNoComment() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
          SizedBox(
            height: 30,
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
      },
    );
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
                  buildLikeDetailSection(),
                  buildCommentLayout(),
                  SizedBox(
                    height: 20,
                  ),
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
