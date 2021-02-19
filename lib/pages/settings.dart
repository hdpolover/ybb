import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/settings/my_account.dart';
import 'package:ybb/pages/settings/privacy_policies.dart';
import 'package:ybb/pages/settings/send_feedback.dart';
import 'package:ybb/pages/settings/terms_cons.dart';
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

  move(int index) {
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyAccount(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendFeedback(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrivacyPoliciesView(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TermsConditionsView(),
          ),
        );
        break;
      default:
        logout();
        break;
    }
  }

  Padding buildSettingList(Icon icon, String text, int index) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: FlatButton(
        highlightColor: null,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: Row(
            children: [
              icon,
              SizedBox(width: 10),
              Text(text),
            ],
          ),
        ),
        onPressed: () => move(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Settings", removeBackButton: false),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildSettingList(
              Icon(Icons.account_circle_outlined), "My Account", 1),
          buildSettingList(Icon(Icons.feedback_outlined), "Send Feedback", 2),
          buildSettingList(
              Icon(Icons.privacy_tip_outlined), "Privacy Policies", 3),
          buildSettingList(
              Icon(Icons.library_books), "Terms and Conditions", 4),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FlatButton(
              highlightColor: null,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 10),
                    Text("Sign out"),
                  ],
                ),
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
