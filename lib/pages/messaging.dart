import 'package:flutter/material.dart';
import 'package:ybb/helpers/constants.dart';
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ClipOval(
              child: Container(
                height: size.height * 0.05,
                width: size.width * 0.12,
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
                style: appBarTextStyle,
              ),
            ),
          ],
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(),
    );
  }
}
