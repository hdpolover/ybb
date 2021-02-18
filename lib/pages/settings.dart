import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<ProfileSettings> {
  String _projectVersion = '';
  String _appName = '';

  @override
  initState() {
    super.initState();

    initPlatformState();
  }

  initPlatformState() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String projectVersion = packageInfo.version;

    if (!mounted) return;

    setState(() {
      _projectVersion = projectVersion;
      _appName = appName;
    });
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

  Container buildAppVersion() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_appName),
        Text(" v "),
        Text(_projectVersion),
        SizedBox(height: 30),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          defaultAppBar(context, titleText: "Settings", removeBackButton: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: OutlinedButton(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text("Sign out"),
              ),
              onPressed: logout,
            ),
          ),
          Spacer(),
          buildAppVersion(),
        ],
      ),
    );
  }
}
