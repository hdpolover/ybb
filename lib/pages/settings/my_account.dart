import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/progress.dart';

class MyAccount extends StatefulWidget {
  MyAccount({Key key}) : super(key: key);

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  buildProfileInfo() {
    return FutureBuilder(
      future: usersRef.doc(currentUser.id).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(snapshot.data);

        return Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              CircleAvatar(
                radius: 60.0,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              SizedBox(height: 20.0),
              Text(
                "Account Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: fontName,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Display name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: fontName,
                      ),
                    ),
                    Spacer(),
                    Text(
                      user.displayName,
                      style: TextStyle(
                          fontFamily: fontName, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Username",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: fontName,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "@" + user.username,
                      style: TextStyle(
                          fontFamily: fontName, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: fontName,
                      ),
                    ),
                    Spacer(),
                    Text(
                      user.email,
                      style: TextStyle(
                          fontFamily: fontName, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Registered on",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: fontName,
                      ),
                    ),
                    Spacer(),
                    Text(
                      convertDateTime(user.timestamp),
                      style: TextStyle(
                          fontFamily: fontName, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String convertDateTime(DateTime postedDate) {
    return DateFormat.yMMMd().add_jm().format(postedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, titleText: "My Account"),
      body: Container(
        child: buildProfileInfo(),
      ),
    );
  }
}
