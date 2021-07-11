import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/commenter.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/post_detail.dart';
import 'package:ybb/pages/profile.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ybb/widgets/shimmers/comment_shimmer_layout.dart';

class ActivityFeed extends StatefulWidget {
  final AppUser currentUser;
  final String userId;

  ActivityFeed({this.currentUser, this.userId});

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed>
    with AutomaticKeepAliveClientMixin<ActivityFeed> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ActivityFeedItem> feedItems = [];
  List<String> feedIds = [];

  @override
  void initState() {
    super.initState();

    if (widget.currentUser == null) {
      getUser();
    } else {
      getActivityFeed();
    }
  }

  getUser() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(widget.userId)
        .collection('feedItems')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(50)
        .get();

    feedItems = [];
    snapshot.docs.forEach((doc) {
      ActivityFeedItem item = ActivityFeedItem.fromDocument(doc);
      feedIds.add(item.feedId);

      feedItems.add(item);
    });

    return feedItems;
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
      ActivityFeedItem item = ActivityFeedItem.fromDocument(doc);
      feedIds.add(item.feedId);

      feedItems.add(item);
    });

    return feedItems;
  }

  Future<Null> refreshActivityFeed() async {
    refreshkey.currentState?.show(atTop: true);

    setState(() {
      feedItems = [];
    });

    await buildActivityFeed();
  }

  buildActivityFeed() {
    return StreamBuilder(
      stream: activityFeedRef
          .doc(widget.currentUser.id)
          .collection('feedItems')
          .orderBy(
            'timestamp',
            descending: true,
          )
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CommentShimmer();
        }

        feedItems = [];
        snapshot.data.documents.forEach(
          (doc) {
            feedItems.add(ActivityFeedItem.fromDocument(doc));
          },
        );

        return feedItems.length == 0
            ? buildNoFeed()
            : Column(children: feedItems);
      },
    );
  }

  buildNoFeed() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/no_notif.svg',
            height: MediaQuery.of(context).size.width * 0.4,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Text(
            "You are all caught up. Nothing to see here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontName,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.4),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  buildAppbar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        "Activity Feed",
        style: appBarTextStyle,
      ),
      elevation: 0,
      actions: <Widget>[
        ConnectivityWidgetWrapper(
          stacked: false,
          offlineWidget: IconButton(
            icon: Icon(Icons.delete, color: Colors.white38),
            onPressed: null,
          ),
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: feedItems == null || feedItems.isEmpty
                  ? Colors.white38
                  : Colors.white,
            ),
            onPressed: feedItems == null || feedItems.isEmpty
                ? null
                : () => handleDeleteFeed(context),
          ),
        ),
      ],
    );
  }

  handleDeleteFeed(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Clear Activity Feed",
            style: TextStyle(
              fontFamily: fontName,
            ),
          ),
          content: Text(
            "Are you sure to clear your Activity Feed? This action cannot be undone.",
            style: TextStyle(
              fontFamily: fontName,
            ),
          ),
          actions: [
            TextButton(
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
            TextButton(
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: fontName,
                ),
              ),
              onPressed: () {
                deleteFeed();

                SnackBar snackBar =
                    SnackBar(content: Text("Activity feed deleted"));
                _scaffoldKey.currentState.showSnackBar(snackBar);
                //ScaffoldMessenger.of(context).showSnackBar(snackBar);

                Navigator.of(context).pop();

                buildNoFeed();
              },
            ),
          ],
        );
      },
    );
  }

  deleteFeed() {
    feedIds.forEach(
      (element) {
        activityFeedRef
            .doc(currentUser.id)
            .collection("feedItems")
            .doc(element)
            .get()
            .then(
          (doc) {
            if (doc.exists) {
              doc.reference.delete();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: buildAppbar(),
      body: LiquidPullToRefresh(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.blue,
        animSpeedFactor: 2.5,
        backgroundColor: Colors.white,
        showChildOpacityTransition: false,
        key: refreshkey,
        onRefresh: refreshActivityFeed,
        child: ConnectivityScreenWrapper(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildActivityFeed(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  final String postId;
  final String commentData;
  final DateTime timestamp;
  final String feedId;

  ActivityFeedItem({
    this.userId,
    this.type,
    this.postId,
    this.commentData,
    this.timestamp,
    this.feedId,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'].toDate(),
      feedId: doc['feedId'],
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetail(
          postId: postId,
          userId: currentUser.id,
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
      activityItemText = 'commented: "$commentData" on your post';
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  buildUserPhoto(context) {
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

  buildUserName() {
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

  String convertDateTime(DateTime postedDate) {
    return DateFormat.yMMMd().add_jm().format(postedDate);
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();

    return Container(
      margin: EdgeInsets.only(top: 5),
      child: GestureDetector(
        onTap: () => type == "follow"
            ? showProfile(context, profileId: userId)
            : showPost(context),
        child: Container(
          color: Colors.white54,
          child: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildUserName(),
                RichText(
                  overflow: TextOverflow.visible,
                  text: TextSpan(
                    text: activityItemText,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: fontName,
                    ),
                  ),
                ),
              ],
            ),
            leading: buildUserPhoto(context),
            subtitle: Text(
              timeago.format(timestamp),
              style: TextStyle(
                fontFamily: fontName,
              ),
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
        isFromOutside: true,
      ),
    ),
  );
}
