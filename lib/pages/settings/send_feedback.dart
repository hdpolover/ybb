import 'package:flutter/material.dart';
import 'package:ybb/widgets/default_appbar.dart';

class SendFeedback extends StatefulWidget {
  SendFeedback({Key key}) : super(key: key);

  @override
  _SendFeedbackState createState() => _SendFeedbackState();
}

class _SendFeedbackState extends State<SendFeedback> {
  TextEditingController feedback = new TextEditingController();

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
            onPressed: () {},
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
