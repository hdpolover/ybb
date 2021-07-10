import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/widgets/full_photo.dart';
import 'package:ybb/widgets/user_photo.dart';

import 'home.dart';

class Messaging extends StatefulWidget {
  final AppUser selectedUser;

  const Messaging({this.selectedUser});

  @override
  _MessagingState createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  bool isValid = false;

  String currentUserId = currentUser.id;
  String selectedUserId = "";
  String selectedUserPhoto = "";

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";

  File imageFile;
  bool isLoading = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);
    selectedUserId = widget.selectedUser.id;
    selectedUserPhoto = widget.selectedUser.photoUrl;

    createGroupChatId();
  }

  createGroupChatId() async {
    if (currentUserId.hashCode <= selectedUserId.hashCode) {
      groupChatId = '$currentUserId-$selectedUserId';
    } else {
      groupChatId = '$selectedUserId-$currentUserId';
    }
    print(groupChatId);

    // FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(id)
    //     .update({'chattingWith': peerId});

    setState(() {});
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white, width: 0.5)),
          color: Colors.white),
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child("Chats").child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile);

    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      String timeCreated = DateTime.now().millisecondsSinceEpoch.toString();
      var documentReference =
          messagesRef.doc(groupChatId).collection(groupChatId).doc(timeCreated);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': currentUserId,
            'idTo': selectedUserId,
            'timestamp': timeCreated,
            'content': content,
            'type': type
          },
        );
      });

      updateMessageList(timeCreated, content, type);

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  void updateMessageList(String time, String content, int type) async {
    await messageListsRef
        .doc(currentUserId)
        .collection("lastMessage")
        .doc(groupChatId)
        .get()
        .then(
      (doc) {
        if (doc.exists) {
          doc.reference.update({
            'idFrom': currentUserId,
            'idTo': selectedUserId,
            'timestamp': time,
            'content': content,
            'type': type
          });
        } else {
          doc.reference.set({
            'idFrom': currentUserId,
            'idTo': selectedUserId,
            'timestamp': time,
            'content': content,
            'type': type
          });
        }
      },
    );

    await messageListsRef
        .doc(selectedUserId)
        .collection("lastMessage")
        .doc(groupChatId)
        .get()
        .then(
      (doc) {
        if (doc.exists) {
          doc.reference.update({
            'idFrom': selectedUserId,
            'idTo': currentUserId,
            'timestamp': time,
            'content': content,
            'type': type
          });
        } else {
          doc.reference.set({
            'idFrom': selectedUserId,
            'idTo': currentUserId,
            'timestamp': time,
            'content': content,
            'type': type
          });
        }
      },
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document != null) {
      if (document.get('idFrom') == currentUserId) {
        // Right (my message)
        return Row(
          children: <Widget>[
            document.get('type') == 0
                // Text
                ? Container(
                    child: Text(
                      document.get('content'),
                      style: TextStyle(color: Colors.blue),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0),
                  )
                : Container(
                    child: OutlinedButton(
                      child: Material(
                        child: Image.network(
                          document.get("content"),
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                color: greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              width: 200.0,
                              height: 200.0,
                              child: Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: primaryColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return Material(
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            );
                          },
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullPhoto(
                              url: document.get('content'),
                            ),
                          ),
                        );
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(0))),
                    ),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0),
                  )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          child: Image.network(
                            selectedUserPhoto,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: primaryColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 35,
                                color: greyColor,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Container(width: 35.0),
                  document.get('type') == 0
                      ? Container(
                          child: Text(
                            document.get('content'),
                            style: TextStyle(color: Colors.white),
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: 200.0,
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8.0)),
                          margin: EdgeInsets.only(left: 10.0),
                        )
                      : Container(
                          child: TextButton(
                            child: Material(
                              child: Image.network(
                                document.get('content'),
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: primaryColor,
                                        value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null &&
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, object, stackTrace) =>
                                    Material(
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullPhoto(
                                          url: document.get('content'))));
                            },
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.all(0))),
                          ),
                          margin: EdgeInsets.only(left: 10.0),
                        )
                ],
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document.get('timestamp')))),
                        style: TextStyle(
                            color: greyColor,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      margin:
                          EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                    )
                  : Container()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') == currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') != currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          onTap: () => showProfile(context, profileId: widget.selectedUser.id),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ClipOval(
                child: Container(
                  height: size.height * 0.04,
                  width: size.width * 0.09,
                  child: PhotoWidget(
                    photoLink: widget.selectedUser.photoUrl,
                  ),
                ),
              ),
              SizedBox(
                width: size.width * 0.03,
              ),
              Expanded(
                child: Text(
                  widget.selectedUser.displayName,
                  style: messageTextStyle,
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).size.height * 0.06,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/chat_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              // List of messages
              buildListMessage(),
              // Input content
              buildInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const CircularProgressIndicator() : Container(),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage.addAll(snapshot.data.docs);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data?.docs[index]),
                    itemCount: snapshot.data.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
    );
  }
}
