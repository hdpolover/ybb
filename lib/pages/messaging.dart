import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/widgets/user_photo.dart';

class Messaging extends StatefulWidget {
  final AppUser currentUser, selectedUser;

  const Messaging({this.currentUser, this.selectedUser});

  @override
  _MessagingState createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  bool isValid = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        elevation: size.height * 0.02,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ClipOval(
              child: Container(
                height: size.height * 0.06,
                width: size.height * 0.06,
                child: PhotoWidget(
                  photoLink: widget.selectedUser.photoUrl,
                ),
              ),
            ),
            SizedBox(
              width: size.width * 0.03,
            ),
            Expanded(
              child: Text(widget.selectedUser.displayName),
            ),
          ],
        ),
      ),
      body: Container(),
    );
  }
}
