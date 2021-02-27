import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/comments.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String displayName;
  final String description;
  final DateTime timestamp;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.displayName,
    this.description,
    this.timestamp,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      displayName: doc['displayName'],
      description: doc['description'],
      timestamp: doc['timestamp'].toDate(),
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
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

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        displayName: this.displayName,
        description: this.description,
        timestamp: this.timestamp,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String displayName;
  final String description;
  final DateTime timestamp;
  final String mediaUrl;
  bool showHeart = false;
  bool isLiked;
  int likeCount;
  Map likes;
  bool isExtended;

  _PostState({
    this.postId,
    this.ownerId,
    this.displayName,
    this.description,
    this.timestamp,
    this.mediaUrl,
    this.likes,
    this.likeCount,
    this.isExtended,
  });

  String convertDateTime(DateTime postedDate) {
    return DateFormat.yMMMd().add_jm().format(postedDate);
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () => showProfile(context, profileId: user.id),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    backgroundColor: Colors.grey,
                    radius: 23,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () => showProfile(context, profileId: user.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.displayName,
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        //convertDateTime(timestamp),
                        timeago.format(timestamp),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
            isPostOwner
                ? IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => handleDeletePost(context),
                  )
                : Text(''),
          ],
        );
        // return ListTile(
        //   leading: CircleAvatar(
        //     backgroundImage: CachedNetworkImageProvider(user.photoUrl),
        //     backgroundColor: Colors.grey,
        //   ),
        //   title: GestureDetector(
        //     onTap: () => showProfile(context, profileId: user.id),
        //     child: Text(
        //       user.displayName,
        //       style: TextStyle(
        //         color: Colors.black,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        //   subtitle: Text(convertDateTime(timestamp)),
        //   trailing: isPostOwner
        //       ? IconButton(
        //           onPressed: () => handleDeletePost(context),
        //           icon: Icon(Icons.more_vert),
        //         )
        //       : Text(''),
        // );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete Post"),
            content: Text(
                "Are you sure to delete this post? This action cannot be undone."),
            actions: [
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  deletePost();
                },
              ),
            ],
            // return SimpleDialog(
            //   title: Text("Remove this post?"),
            //   children: <Widget>[
            //     SimpleDialogOption(
            //       onPressed: () {
            //         Navigator.pop(context);
            //         deletePost();
            //       },
            //       child: Text(
            //         'Delete',
            //         style: TextStyle(color: Colors.red),
            //       ),
            //     ),
            //   ],
          );
        });
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    // delete post itself
    postsRef.doc(ownerId).collection('userPosts').doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for thep ost
    storageRef.child("Posts").child("post_$postId.jpg").delete();
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postId).collection('comments').get();
    commentsSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        isExtended = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        isExtended = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection("feedItems").doc(postId).set({
        "type": "like",
        "displayName": currentUser.displayName,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
        "commentData": "",
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildLikeAndComment() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "$likeCount likes",
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          "500 comments",
          style: TextStyle(color: Colors.grey[600]),
        )
      ],
    );
  }

  buildPostImage() {
    return GestureDetector(
      onTap: () {},
      onDoubleTap: handleLikePost,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
            alignment: Alignment.topLeft,
            child: Text(
              manageDesc(description),
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.5,
                  letterSpacing: .7),
            ),
          ),
          CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  String manageDesc(String desc) {
    if (desc.trim().length > 400) {
      //return desc.substring(0, 400) + "...";
      return desc;
    } else {
      return desc;
    }
  }

  int comments = 0;
  getCommentCount() async {
    QuerySnapshot snapshot =
        await commentsRef.doc(postId).collection('comments').get();

    dynamic comments = snapshot.docs.map((doc) => doc.id).toList();

    if (comments == null) {
      return 0;
    }
    int commentCount = 0;
    // if the key is explicitly set to true, add a like
    comments.forEach((val) {
      commentCount += 1;
    });

    comments = commentCount;
    return commentCount;
  }

  buildPostFooter() {
    return Row(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: handleLikePost,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      isLiked
                          ? Icon(
                              Icons.thumb_up,
                              size: 30.0,
                              color: Colors.blue,
                            )
                          : Icon(
                              Icons.thumb_up_alt_outlined,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Like",
                        style: TextStyle(
                            color: isLiked ? Colors.blue : Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.chat, color: Colors.grey, size: 30),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Comment",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    isExtended = true;

    return Container(
      margin: EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildPostHeader(),
          SizedBox(height: 10),
          buildPostImage(),
          SizedBox(height: 20),
          buildLikeAndComment(),
          SizedBox(height: 15),
          buildPostFooter()
        ],
      ),
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
