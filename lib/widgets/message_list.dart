import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ybb/pages/messaging.dart';
import 'package:ybb/widgets/shimmers/comment_shimmer_layout.dart';

class MessageList extends StatefulWidget {
  final String content, idFrom, idTo, timestamp, type;

  MessageList({
    this.content,
    this.idFrom,
    this.idTo,
    this.type,
    this.timestamp,
  });

  factory MessageList.fromDocument(DocumentSnapshot doc) {
    return MessageList(
        content: doc['content'],
        idFrom: doc['idFrom'],
        idTo: doc['idTo'],
        type: doc['type'].toString(),
        timestamp: doc['timestamp']);
  }

  @override
  _MessageListState createState() => _MessageListState(
        idFrom: this.idFrom,
        idTo: this.idTo,
        content: this.content,
        type: this.type,
        timestamp: this.timestamp,
      );
}

class _MessageListState extends State<MessageList> {
  String idFrom;
  String idTo;
  String content;
  String type;
  String timestamp;

  _MessageListState({
    this.content,
    this.idFrom,
    this.idTo,
    this.timestamp,
    this.type,
  });

  AppUser user;

  buildChatListTile() {
    return FutureBuilder(
      future: usersRef.doc(idTo).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CommentShimmer();
        }

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

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Messaging(
                  selectedUser: user,
                ),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
            radius: 25,
          ),
          title: Text(
            user.displayName.length > 18
                ? user.displayName.substring(0, 18) + "..."
                : user.displayName,
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: fontName,
              letterSpacing: 1,
            ),
          ),
          subtitle: type == "1"
              ? Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: greyColor,
                    ),
                    Text(
                      " image",
                      style: TextStyle(
                        color: greyColor,
                        fontFamily: fontName,
                      ),
                    ),
                  ],
                )
              : Text(
                  content.length > 30
                      ? content.substring(0, 30) + "..."
                      : content,
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: fontName,
                  ),
                ),
          trailing: Text(
            timeago.format(
                DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp))),
            style: TextStyle(
              color: Colors.grey,
              fontFamily: fontName,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildChatListTile();
  }
}
