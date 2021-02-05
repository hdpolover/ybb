import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';

class ProfileSettings extends StatefulWidget {
  ProfileSettings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<ProfileSettings> {
  String _projectVersion = '';
  String _buildNumber = '';
  String _packageName = '';
  String _appName = '';

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String projectVersion = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    if (!mounted) return;

    setState(() {
      _projectVersion = projectVersion;
      _buildNumber = buildNumber;
      _packageName = packageName;
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
      child: RichText(
        text: TextSpan(
          text: _projectVersion + ' ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(text: _appName, style: DefaultTextStyle.of(context).style),
          ],
        ),
      ),
    );
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
