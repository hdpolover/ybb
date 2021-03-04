import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ybb/models/chat.dart';
import 'package:ybb/models/message.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/messaging.dart';
import 'package:ybb/repositories/message_repository.dart';
import 'package:ybb/widgets/page_turn.dart';
import 'package:ybb/widgets/user_photo.dart';

class ChatWidget extends StatefulWidget {
  final String userId, selectedUserId;
  final Timestamp creationTime;

  const ChatWidget({this.userId, this.selectedUserId, this.creationTime});

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  MessageRepository messageRepository = MessageRepository();
  Chat chat;
  AppUser user;

  getUserDetail() async {
    user = await messageRepository.getUserDetail(userId: widget.selectedUserId);
    Message message = await messageRepository
        .getLastMessage(
            currentUserId: widget.userId, selectedUserId: widget.selectedUserId)
        .catchError((error) {
      print(error);
    });

    if (message == null) {
      return Chat(
        name: user.displayName,
        photoUrl: user.photoUrl,
        lastMessage: null,
        lastMessagePhoto: null,
        timestamp: null,
      );
    } else {
      return Chat(
        name: user.displayName,
        photoUrl: user.photoUrl,
        lastMessagePhoto: message.photoUrl,
        timestamp: message.timestamp,
      );
    }
  }

  openChat() async {
    AppUser currentUser =
        await messageRepository.getUserDetail(userId: widget.userId);
    AppUser selectedUser =
        await messageRepository.getUserDetail(userId: widget.selectedUserId);

    try {
      pageTurn(Messaging(currentUser: currentUser, selectedUser: selectedUser),
          context);
    } catch (e) {
      print(e.toString());
    }
  }

  deleteChat() async {
    await messageRepository.deleteChat(
        currentUserId: widget.userId, selectedUserId: widget.selectedUserId);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: getUserDetail(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          Chat chat = snapshot.data;
          return GestureDetector(
            onTap: () async {
              await openChat();
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        content: Wrap(
                          children: <Widget>[
                            Text(
                              "Do you want to delete this chat",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "This action is irreversible.",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "No",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          FlatButton(
                            onPressed: () async {
                              await deleteChat();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ));
            },
            child: Padding(
              padding: EdgeInsets.all(size.height * 0.02),
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.height * 0.02),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ClipOval(
                          child: Container(
                            height: size.height * 0.06,
                            width: size.height * 0.06,
                            child: PhotoWidget(
                              photoLink: user.photoUrl,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              user.displayName,
                              style: TextStyle(fontSize: size.height * 0.03),
                            ),
                            chat.lastMessage != null
                                ? Text(
                                    chat.lastMessage,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : chat.lastMessagePhoto == null
                                    ? Text("Chat Room Open")
                                    : Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.photo,
                                            color: Colors.grey,
                                            size: size.height * 0.02,
                                          ),
                                          Text(
                                            "Photo",
                                            style: TextStyle(
                                              fontSize: size.height * 0.015,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                          ],
                        ),
                      ],
                    ),
                    chat.timestamp != null
                        ? Text(timeago.format(chat.timestamp.toDate()))
                        : Text(timeago.format(widget.creationTime.toDate()))
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
