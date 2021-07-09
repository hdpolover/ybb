import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/create_new_message.dart';

import 'home.dart';

class Messages extends StatefulWidget {
  final AppUser currentUser;
  final String userId;

  Messages({this.currentUser, this.userId});

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages>
    with AutomaticKeepAliveClientMixin<Messages> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> chatList = [];

  @override
  void initState() {
    super.initState();

    if (widget.currentUser == null) {
      getUser();
    } else {
      getActivityFeed();
    }
  }

  buildAppbar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        "Messages",
        style: appBarTextStyle,
      ),
      elevation: 0,
      // actions: <Widget>[
      //   ConnectivityWidgetWrapper(
      //     stacked: false,
      //     offlineWidget: IconButton(
      //       icon: Icon(Icons.delete, color: Colors.white38),
      //       onPressed: null,
      //     ),
      //     child: IconButton(
      //       icon: Icon(
      //         Icons.delete,
      //         color: feedItems == null || feedItems.isEmpty
      //             ? Colors.white38
      //             : Colors.white,
      //       ),
      //       onPressed: feedItems == null || feedItems.isEmpty
      //           ? null
      //           : () => handleDeleteFeed(context),
      //     ),
      //   ),
      // ],
    );
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

    // feedItems = [];
    // snapshot.docs.forEach((doc) {
    //   ActivityFeedItem item = ActivityFeedItem.fromDocument(doc);
    //   feedIds.add(item.feedId);

    //   feedItems.add(item);
    // });

    return false;
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

    // feedItems = [];
    // snapshot.docs.forEach((doc) {
    //   ActivityFeedItem item = ActivityFeedItem.fromDocument(doc);
    //   feedIds.add(item.feedId);

    //   feedItems.add(item);
    // });

    return false;
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

  Future<Null> refreshActivityFeed() async {
    refreshkey.currentState?.show(atTop: true);

    chatList = [];

    //await buildMessagesMain();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: buildAppbar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.message,
          color: Colors.white,
        ), //child widget inside this button
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewMessage(),
            ),
          );
        },
      ),
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
                buildNoFeed(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
