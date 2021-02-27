import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/pages/home.dart';

class SendFeedback extends StatefulWidget {
  final User user;

  SendFeedback({this.user});

  @override
  _SendFeedbackState createState() => _SendFeedbackState();
}

class _SendFeedbackState extends State<SendFeedback> {
  TextEditingController feedback = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String feedbackId = Uuid().v4();

  final ybbEmail = "ybb.admn@gmail.com";
  final subject = "YBB App Feedback";

  Widget buildFeedback() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Tell us what we could improve about this app.",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: feedback,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Feedback",
              labelStyle: TextStyle(fontSize: 15.0),
              hintText: "Write something here...",
            ),
          ),
          SizedBox(height: 15),
          FlatButton(
            textColor: Colors.white,
            height: 50.0,
            color: Theme.of(context).primaryColor,
            onPressed: send,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'SUBMIT',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  send() {
    feedbackRef.doc(feedbackId).set({
      "feedback": feedback.text,
      "timestamp": DateTime.now(),
      "userId": currentUser.id,
    });

    setState(() {
      feedbackId = Uuid().v4();
    });

    // final Email email = Email(
    //   body: feedback.text,
    //   subject: subject,
    //   recipients: [ybbEmail],
    // );

    // String platformResponse;

    // try {
    //   await FlutterEmailSender.send(email);
    //   platformResponse = 'success';
    // } catch (error) {
    //   platformResponse = error.toString();
    // }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Feedback succesfully submitted!"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, titleText: "Send Feedback"),
      body: Container(
        child: buildFeedback(),
      ),
    );
  }
}
