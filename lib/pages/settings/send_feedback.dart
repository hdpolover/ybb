import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:ybb/helpers/constants.dart';
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
  FocusNode focusNode;

  String feedbackId = Uuid().v4();
  bool isValid = true;
  bool isChosen = false;
  String feedbackType = "";

  final ybbEmail = "ybb.admn@gmail.com";
  final subject = "YBB App Feedback";

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

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
              fontFamily: fontName,
            ),
          ),
          SizedBox(height: 15),
          DropDownFormField(
            errorText: isChosen ? null : "Please select one",
            filled: false,
            titleText: 'Feedback Type',
            value: feedbackType,
            onChanged: (value) {
              setState(() {
                feedbackType = value;
              });
            },
            dataSource: [
              {
                "display": "New features",
                "value": "newFeatures",
              },
              {
                "display": "Improvements/Fixes",
                "value": "fix",
              },
              {
                "display": "Errors/bugs",
                "value": "errors",
              },
              {
                "display": "Others",
                "value": "others",
              },
            ],
            textField: 'display',
            valueField: 'value',
          ),
          SizedBox(height: 15),
          TextFormField(
            focusNode: focusNode,
            controller: feedback,
            minLines: 3,
            maxLines: 10,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                fontSize: 15.0,
                fontFamily: fontName,
              ),
              hintText: "Write something here...",
              errorText: isValid ? null : "Feedback cannot be empty",
            ),
          ),
          SizedBox(height: 15),
          FlatButton(
            textColor: Colors.white,
            height: 50.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              send();
            },
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
                  style: TextStyle(fontFamily: fontName),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  send() {
    focusNode.unfocus();

    if (feedbackType.isEmpty || feedbackType == null) {
      setState(() {
        isChosen = false;
      });
    } else {
      setState(() {
        isChosen = true;
      });
    }
    print(feedbackType);

    setState(() {
      feedback.text.isEmpty ? isValid = false : isValid = true;
    });

    if (isValid && isChosen) {
      feedbackRef.doc(feedbackId).set({
        "feedback": feedback.text,
        "type": feedbackType,
        "timestamp": DateTime.now(),
        "userId": currentUser.id,
        "feedbackId": feedbackId,
      });

      setState(() {
        feedback.clear();
        feedbackId = Uuid().v4();
      });

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Feedback succesfully submitted!"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: defaultAppBar(context, titleText: "Send Feedback"),
      body: Container(
        child: buildFeedback(),
      ),
    );
  }
}
