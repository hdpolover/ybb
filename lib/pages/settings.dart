import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/settings/about_app.dart';
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
  static String _projectVersion = '2.1.2';
  static String _appName = 'YBB';

  @override
  initState() {
    super.initState();

    _projectVersion = "2.1.2";
    _appName = "YBB";

    initPlatformState();
  }

  initPlatformState() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = "";
    String projectVersion = "";

    try {
      appName = packageInfo.appName;
      projectVersion = packageInfo.version;
    } catch (e) {
      appName = "YBB";
      projectVersion = "2.1.2";
    }

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
        Text(
          _appName == null ? "YBB" : _appName,
          style: TextStyle(fontFamily: fontName),
        ),
        Text(
          " v",
          style: TextStyle(fontFamily: fontName),
        ),
        Text(
          _projectVersion == null ? "0.0.0" : _projectVersion,
          style: TextStyle(fontFamily: fontName),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AboutApp(
              appName: _appName,
              appVersion: _projectVersion,
            ),
          ),
        );
        break;
      default:
        logout();
        break;
    }
  }

  Container buildSettingList(Icon icon, String text, int index) {
    return Container(
      child: ConnectivityWidgetWrapper(
        stacked: false,
        offlineWidget: Padding(
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
                  Text(
                    text,
                    style:
                        TextStyle(fontFamily: fontName, color: Colors.black38),
                  ),
                ],
              ),
            ),
            onPressed: null,
          ),
        ),
        child: Padding(
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
                  Text(
                    text,
                    style: TextStyle(fontFamily: fontName),
                  ),
                ],
              ),
            ),
            onPressed: () => move(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Settings", removeBackButton: false),
      body: ConnectivityScreenWrapper(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildSettingList(
                Icon(Icons.account_circle_outlined), "My Account", 1),
            buildSettingList(
                Icon(Icons.announcement_outlined), "Send Feedback", 2),
            buildSettingList(
                Icon(Icons.privacy_tip_outlined), "Privacy Policies", 3),
            buildSettingList(
                Icon(Icons.library_books), "Terms and Conditions", 4),
            buildSettingList(Icon(Icons.device_unknown), "About App", 5),
            ConnectivityWidgetWrapper(
              stacked: false,
              offlineWidget: Padding(
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
                        Text("Sign out",
                            style: TextStyle(
                              fontFamily: fontName,
                              color: Colors.black38,
                            )),
                      ],
                    ),
                  ),
                  onPressed: null,
                ),
              ),
              child: Padding(
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
                        Text("Sign out",
                            style: TextStyle(fontFamily: fontName)),
                      ],
                    ),
                  ),
                  onPressed: logout,
                ),
              ),
            ),
            Spacer(),
            buildAppVersion(),
          ],
        ),
      ),
    );
  }
}
