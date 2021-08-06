import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:launch_review/launch_review.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/widgets/default_appbar.dart';

class AboutApp extends StatefulWidget {
  final String appName;
  final String appVersion;

  AboutApp({this.appName, this.appVersion});

  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ybbEmail = "ybb.admn@gmail.com";
  final developerEmail = "hendrapolover@gmail.com";

  final androidId = "com.hdpolover.ybbproject";
  final iosId = "1554311405";

  Widget buildLayout() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Image(
              image: AssetImage('assets/images/ybb_black_full.png'),
              height: MediaQuery.of(context).size.width * 0.3,
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.1),
            Text(
              "v" + widget.appVersion,
              style: TextStyle(
                fontFamily: fontName,
                color: Colors.black,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.1),
            FlatButton(
              textColor: Colors.blue,
              color: Colors.white10,
              onPressed: () {
                try {
                  sendEmail();
                } catch (e) {
                  Fluttertoast.showToast(
                    msg:
                        "An error occured. Make sure you have installed GMail on your device.",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 1,
                  );
                }
              },
              child: Text('Contact Developer',
                  style: TextStyle(
                    fontFamily: fontName,
                    color: Colors.blue,
                  )),
            ),
            FlatButton(
              textColor: Colors.blue,
              color: Colors.white10,
              onPressed: () =>
                  LaunchReview.launch(androidAppId: androidId, iOSAppId: iosId),
              child: Text('Rate YBB App',
                  style: TextStyle(
                    fontFamily: fontName,
                    color: Colors.blue,
                  )),
            ),
            Spacer(),
            Text(
              "2021 \u00a9 Youth Break the Boundaries Foundation",
              style: TextStyle(
                fontFamily: fontName,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendEmail() async {
    final Email email = Email(
      cc: [ybbEmail],
      recipients: [developerEmail],
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'Email successfully delivered';
    } catch (error) {
      platformResponse = error.toString();
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(platformResponse),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, titleText: "About App"),
      body: Container(
        child: buildLayout(),
      ),
    );
  }
}
