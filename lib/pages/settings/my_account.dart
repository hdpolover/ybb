import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/profile_dashboard_shimmer_layout.dart';

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
          return ProfileDashboardShimmer();
        }

        AppUser user = AppUser.fromDocument(snapshot.data);

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
                      convertDateTime(user.registerDate),
                      style: TextStyle(
                          fontFamily: fontName, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              // TextButton.icon(
              //   icon: FaIcon(FontAwesomeIcons.trash),
              //   label: Text("Deactivate account"),
              //   style: TextButton.styleFrom(
              //     backgroundColor: Colors.red,
              //     onSurface: Colors.white,
              //     primary: Colors.white,
              //   ),
              //   onPressed: () => handleDeletePost(context),
              // )
            ],
          ),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Deactivate Account",
              style: TextStyle(
                fontFamily: fontName,
              ),
            ),
            content: Text(
              "You are about to deactivate your account. This action cannot be undone and all your data will be erased. Are you sure?",
              style: TextStyle(
                fontFamily: fontName,
              ),
            ),
            actions: [
              FlatButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: fontName,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  "Deactivate",
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: fontName,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  deactivateAccount();
                },
              ),
            ],
          );
        });
  }

  deactivateAccount() async {
    logout();
  }

  logout() async {
    await googleSignIn.signOut();

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
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
