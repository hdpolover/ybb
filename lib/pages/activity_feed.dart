import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

class _ActivityFeedState extends State<ActivityFeed>
    with AutomaticKeepAliveClientMixin<ActivityFeed> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  List<ActivityFeedItem> feedItems = [];

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

    feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });

    return feedItems;
  }

  Future<Null> refreshActivityFeed() async {
    refreshkey.currentState?.show(atTop: true);

    setState(() {
      feedItems = [];
    });

    await getActivityFeed();
  }

  buildNoFeed() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/no_notif.svg',
            height: 170,
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            "You are all caught up. Nothing to see here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: defaultAppBar(
        context,
        titleText: "Activity Feed",
        removeBackButton: true,
      ),
      body: RefreshIndicator(
        key: refreshkey,
        onRefresh: refreshActivityFeed,
        child: Container(
            child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }

            return feedItems.length == 0
                ? buildNoFeed()
                : ListView(
                    children: snapshot.data,
                  );
          },
        )),
      ),
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
      activityItemText = "liked your post.";
    } else if (type == 'follow') {
      activityItemText = "started following you.";
    } else if (type == 'comment') {
      activityItemText = 'replied: "$commentData"';
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
      elevation: 0,
      child: GestureDetector(
        //onTap: () => showPost(context),
        onTap: () {},
        child: Container(
          color: Colors.white54,
          child: ListTile(
            title: GestureDetector(
              onTap: () => showProfile(context, profileId: userId),
              child: Container(
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
            ),
            leading: GestureDetector(
              onTap: () => showProfile(context, profileId: userId),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(userProfileImg),
              ),
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

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
