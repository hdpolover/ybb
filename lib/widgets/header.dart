import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/upload_post.dart';

AppBar header(context,
    {bool isAppTitle = false,
    String titleText,
    removeBackButton = false,
    AppUser currentUser}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Padding(
      padding: EdgeInsets.all(9),
      child: Image(
        image: AssetImage('assets/images/ybb_putih_cropped.png'),
        height: 35,
      ),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    elevation: 0,
    actions: <Widget>[
      ConnectivityWidgetWrapper(
        stacked: false,
        offlineWidget: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white38,
              ),
              onPressed: null,
            ),
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.white38,
              ),
              onPressed: null,
            ),
          ],
        ),
        child: Row(
          children: [
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
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityFeed(
                      currentUser: currentUser,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ],
  );
}
