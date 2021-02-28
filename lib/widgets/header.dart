import 'package:flutter/material.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/upload_post.dart';

AppBar header(context,
    {bool isAppTitle = false,
    String titleText,
    removeBackButton = false,
    User currentUser}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Padding(
      padding: EdgeInsets.all(9),
      child: Image(
        image: AssetImage('assets/images/ybb_putih_cropped.png'),
        height: 35,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
    elevation: 0,
    actions: <Widget>[
      IconButton(
        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadPost(
                currentUser: currentUser,
              ),
            ),
          );
        },
      ),
    ],
  );
}
