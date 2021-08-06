import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/create_new_message.dart';
import 'package:ybb/widgets/message_list.dart';
import 'package:ybb/widgets/shimmers/comment_shimmer_layout.dart';

import 'home.dart';

class Messages extends StatefulWidget {
  final AppUser currentUser;
  final String userId;

  Messages({this.currentUser, this.userId});

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<MessageList> finalMessages = [];
  String currentUserId;

  @override
  void initState() {
    super.initState();

    currentUserId = currentUser.id;
    getMessageList();
  }

  getMessageList() async {
    QuerySnapshot list = await messageListsRef
        .doc(currentUserId)
        .collection("lastMessage")
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      list.docs.forEach(
        (doc) {
          finalMessages.add(MessageList.fromDocument(doc));
        },
      );
    });
  }

  // buildMessageAll() {
  //   if (finalMessages == null) {
  //     return CommentShimmer();
  //   } else if (finalMessages.length == 0) {
  //     return CommentShimmer();
  //   } else {
  //     return buildMessageList();
  //   }
  // }

  buildMessageList() {
    return StreamBuilder(
      stream: messageListsRef
          .doc(currentUserId)
          .collection("lastMessage")
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        // List<MessageList> finalMessages = List<MessageList>.from(
        //     snapshot.data.docs.map((doc) => MessageList.fromDocument(doc)));

        // finalMessages = [];
        // snapshot.data.documents.forEach(
        //   (doc) {
        //     finalMessages.add(MessageList.fromDocument(doc));
        //   },
        // );

        return finalMessages == null
            ? CommentShimmer()
            : finalMessages.length == 0
                ? buildNoFeed()
                : ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: finalMessages.length,
                    itemBuilder: (context, index) {
                      return finalMessages[index];
                    },
                  );
      },
    );
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  buildNoFeed() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
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
            "Start a new chat with people you're following.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontName,
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> refreshActivityFeed() async {
    refreshkey.currentState?.show(atTop: true);

    setState(() {
      finalMessages = [];
    });

    await getMessageList();
    buildMessageList();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
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
          child: buildMessageList(),
        ),
      ),
    );
  }
}
