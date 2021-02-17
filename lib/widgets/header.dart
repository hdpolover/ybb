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
    title: Text(
      isAppTitle ? "YBB" : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Montserrat" : "",
        fontSize: isAppTitle ? 25.0 : 22.0,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    //centerTitle: true,
    backgroundColor: Colors.blue,
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
      // IconButton(
      //   icon: Icon(
      //     Icons.chat,
      //     color: Colors.white,
      //   ),
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => Messages(),
      //       ),
      //     );
      //   },
      // ),
    ],
  );
}
