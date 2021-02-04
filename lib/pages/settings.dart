import 'package:flutter/material.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';

class ProfileSettings extends StatefulWidget {
  ProfileSettings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<ProfileSettings> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          defaultAppBar(context, titleText: "Settings", removeBackButton: true),
      body: Container(
        child: ListView(
          children: [
            RaisedButton(
              child: Text("logout"),
              onPressed: logout,
            ),
          ],
        ),
      ),
    );
  }
}
