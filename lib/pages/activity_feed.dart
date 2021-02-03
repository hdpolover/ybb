import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/post_screen.dart';
import 'package:ybb/pages/profile.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/progress.dart';

class ActivityFeed extends StatefulWidget {
  final User currentUser;

  ActivityFeed({this.currentUser});

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  void initState() {
    super.initState();

    getActivityFeed();
  }

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(widget.currentUser.id)
        .collection('feedItems')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(50)
        .get();

    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach(
      (doc) {
        feedItems.add(ActivityFeedItem.fromDocument(doc));
      },
    );

    print(feedItems);
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: defaultAppBar(
        context,
        titleText: "Activity Feed",
        removeBackButton: true,
      ),
      body: Container(
          child: FutureBuilder(
        future: getActivityFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return ListView(
            children: snapshot.data,
          );
        },
      )),
    );
  }
}

String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String displayName;
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final DateTime timestamp;

  ActivityFeedItem({
    this.displayName,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      displayName: doc['displayName'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'].toDate(),
      mediaUrl: doc['mediaUrl'],
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  configureMediaPreview() {
    if (type == 'like') {
      activityItemText = "liked your post";
    } else if (type == 'follow') {
      activityItemText = "started following you";
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  String convertDateTime(DateTime postedDate) {
    return DateFormat.yMMMd().add_jm().format(postedDate);
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();

    return Card(
      //padding: EdgeInsets.only(bottom: 2.0),
      child: GestureDetector(
        onTap: () => showProfile(context, profileId: userId, username: "dsdsd"),
        child: Container(
          color: Colors.white54,
          child: ListTile(
            title: Container(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: displayName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' $activityItemText',
                      ),
                    ]),
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
            subtitle: Text(
              convertDateTime(timestamp),
              overflow: TextOverflow.ellipsis,
            ),
            // trailing: mediaPreview,
          ),
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId, String username}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
        username: username,
      ),
    ),
  );
}
