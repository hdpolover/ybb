import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/comments.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/post_likers.dart';
import 'package:ybb/widgets/full_photo.dart';
import 'package:ybb/widgets/shimmers/post_header_shimmer_layout.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String description;
  final DateTime timestamp;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.description,
    this.timestamp,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
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
      description: this.description,
      timestamp: this.timestamp,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      likeCount: getLikeCount(this.likes));
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String description;
  final DateTime timestamp;
  final String mediaUrl;

  bool showHeart = false;
  bool isLiked;
  int likeCount;
  int commentCount = 0;
  Map likes;

  List<String> followers = [];

  _PostState(
      {this.postId,
      this.ownerId,
      this.description,
      this.timestamp,
      this.mediaUrl,
      this.likes,
      this.likeCount});

  @override
  void initState() {
    super.initState();

    getUserId();
    getFollowers();
    getCommentCount();
  }

  Future<void> getFollowers() async {
    QuerySnapshot snapshot =
        await followersRef.doc(ownerId).collection('userFollowers').get();

    followers = snapshot.docs.map((doc) => doc.id).toList();
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return PostHeaderShimmer();
        }

        AppUser user;
        try {
          user = AppUser.fromDocument(snapshot.data);
        } catch (e) {
          user = AppUser(
            id: snapshot.data['id'],
            email: snapshot.data['email'],
            username: snapshot.data['username'],
            photoUrl: snapshot.data['photoUrl'],
            displayName: snapshot.data['displayName'],
            bio: snapshot.data['bio'],
            occupation: snapshot.data['occupation'],
            interests: snapshot.data['interests'],
            registerDate: snapshot.data['registerDate'].toDate(),
            phoneNumber: snapshot.data['phoneNumber'],
            showContacts: snapshot.data['showContacts'],
            instagram: snapshot.data['instagram'],
            facebook: snapshot.data['facebook'],
            website: snapshot.data['website'],
          );
        }

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
                        user.displayName.length > 25
                            ? user.displayName.substring(0, 24) + "..."
                            : user.displayName,
                        style: TextStyle(
                          color: Colors.grey[900],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontName,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        //convertDateTime(timestamp),
                        timeago.format(timestamp),
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: fontName,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            isPostOwner
                ? PopupMenuButton(
                    onSelected: (value) {
                      switch (value) {
                        case 0:
                          handleDeletePost(context);
                          break;
                        default:
                          break;
                      }
                    },
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: fontName,
                          ),
                        ),
                        value: 0,
                      ),
                      // PopupMenuItem(
                      //   child: Text(
                      //     'Share',
                      //     style: TextStyle(
                      //       fontFamily: fontName,
                      //     ),
                      //   ),
                      //   value: 1,
                      // ),
                    ],
                  )
                : Text(''),
          ],
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Delete Post",
              style: TextStyle(
                fontFamily: fontName,
              ),
            ),
            content: Text(
              "Are you sure to delete this post? This action cannot be undone.",
              style: TextStyle(
                fontFamily: fontName,
              ),
            ),
            actions: [
              FlatButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: fontName,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: fontName,
                  ),
                ),
                onPressed: () {
                  deletePost(parentContext);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost(BuildContext contexxt) async {
    // delete post itself
    await postsRef
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // await timelineRef
    //     .doc(ownerId)
    //     .collection("timelinePosts")
    //     .doc(postId)
    //     .get()
    //     .then((doc) {
    //   if (doc.exists) {
    //     doc.reference.delete();
    //   }
    // });

    // //delete from followers timeline
    // if (followers.isNotEmpty) {
    //   for (int i = 0; i < followers.length; i++) {
    //     if (followers[i] != ownerId) {
    //       await timelineRef
    //           .doc(followers[i])
    //           .collection("timelinePosts")
    //           .doc(postId)
    //           .get()
    //           .then((doc) {
    //         if (doc.exists) {
    //           doc.reference.delete();
    //         }
    //       });
    //     }

    //     print("deleted " + i.toString());
    //   }
    // }

    try {
      // delete uploaded image for thep ost
      //storageRef.child("Posts").child("post_$postId.jpg").delete();
      var ref = storageRef.child("Posts").child("pimage_$postId.jpg");
      var downloadUrl = await ref.getDownloadURL();
      var url = downloadUrl.toString();
      if (url != null) {
        ref.delete();
      } else {
        print('no image');
      }
    } catch (e) {
      print('post has no image');
    }

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

  handleLikePost() async {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      await postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});

      // await timelineRef
      //     .doc(currentUserId)
      //     .collection("timelinePosts")
      //     .doc(postId)
      //     .update({'likes.$currentUserId': false});

      // await timelineRef
      //     .doc(ownerId)
      //     .collection("timelinePosts")
      //     .doc(postId)
      //     .update({'likes.$currentUserId': false});

      // //delete from followers timeline
      // if (followers.isNotEmpty) {
      //   for (int i = 0; i < followers.length; i++) {
      //     if (followers[i] != ownerId) {
      //       await timelineRef
      //           .doc(followers[i])
      //           .collection("timelinePosts")
      //           .doc(postId)
      //           .update({'likes.$currentUserId': false});
      //     }

      //     print("updated " + i.toString());
      //   }
      // }

      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      await postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});

      // await timelineRef
      //     .doc(currentUserId)
      //     .collection("timelinePosts")
      //     .doc(postId)
      //     .update({'likes.$currentUserId': true});

      // await timelineRef
      //     .doc(ownerId)
      //     .collection("timelinePosts")
      //     .doc(postId)
      //     .update({'likes.$currentUserId': true});

      // //delete from followers timeline
      // if (followers.isNotEmpty) {
      //   for (int i = 0; i < followers.length; i++) {
      //     if (followers[i] != ownerId) {
      //       await timelineRef
      //           .doc(followers[i])
      //           .collection("timelinePosts")
      //           .doc(postId)
      //           .update({'likes.$currentUserId': true});
      //     }

      //     print("updated " + i.toString());
      //   }
      // }

      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
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
        "userId": currentUser.id,
        "postId": postId,
        "timestamp": DateTime.now(),
        "commentData": "",
        "feedId": postId,
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

  Future<Null> getCommentCount() async {
    try {
      QuerySnapshot snapshot =
          await commentsRef.doc(postId).collection('comments').get();

      setState(() {
        commentCount = snapshot.docs.length;
      });
    } catch (e) {
      commentCount = 0;
    }
  }

  List<String> likerIds = [];

  getUserId() async {
    DocumentSnapshot doc =
        await postsRef.doc(ownerId).collection('userPosts').doc(postId).get();

    Post post = Post.fromDocument(doc);
    Map<String, dynamic> i = post.likes;

    i.entries.forEach((element) {
      if (element.value == true) {
        likerIds.add(element.key);
      }
    });
  }

  showLikers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostLikers(likerIds: likerIds, postId: postId),
      ),
    );
  }

  buildLikeAndComment() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          onTap: () => showLikers(),
          child: Text(
            likeCount < 2 || likeCount == null
                ? "$likeCount like"
                : "$likeCount likes",
            style: TextStyle(
              color: Colors.grey[600],
              fontFamily: fontName,
            ),
          ),
        ),
        Text(
          commentCount < 2 || commentCount == null
              ? "$commentCount comment"
              : "$commentCount comments",
          style: TextStyle(
            color: Colors.grey[600],
            fontFamily: "OpenSans",
          ),
        ),
      ],
    );
  }

  buildPostDescription() {
    return GestureDetector(
      onTap: () => showComments(
        context,
        postId: postId,
        ownerId: ownerId,
        mediaUrl: mediaUrl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 0.0, 10.0, 10.0),
            alignment: Alignment.topLeft,
            child: Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.3,
                letterSpacing: .7,
                fontFamily: fontName,
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  buildPostImage() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullPhoto(url: mediaUrl),
          ),
        );
      },
      onDoubleTap: handleLikePost,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
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
                              size: 25.0,
                              color: Colors.blue,
                            )
                          : Icon(
                              Icons.thumb_up_alt_outlined,
                              color: Colors.grey,
                              size: 25.0,
                            ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Like",
                        style: TextStyle(
                          color: isLiked ? Colors.blue : Colors.grey,
                          fontFamily: fontName,
                        ),
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
                      Icon(
                        Icons.chat,
                        color: Colors.grey,
                        size: 25,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Comment",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: fontName,
                        ),
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

    return Container(
      margin: EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildPostHeader(),
          SizedBox(height: 10),
          buildPostDescription(),
          mediaUrl.isNotEmpty ? buildPostImage() : Container(),
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
