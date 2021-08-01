import 'package:flutter/material.dart';
import 'package:ybb/helpers/api/influencer.dart';
import 'package:ybb/helpers/constants.dart';

class TryRef extends StatefulWidget {
  @override
  _TryRefState createState() => _TryRefState();
}

class _TryRefState extends State<TryRef> {
  TextEditingController refCodeController = new TextEditingController();
  List<Influencer> refCodes = [];

  bool isRefCodeAvailable = false;
  String resultText = "";

  @override
  void initState() {
    super.initState();
    getInfluencers();
  }

  getInfluencers() async {
    List<Influencer> p = await Influencer.getInfluencerRefCodes();

    setState(() {
      refCodes = p;
    });
  }

  Text buildRefCodes() {
    String text = "";

    try {
      for (int i = 0; i < refCodes.length; i++) {
        text += refCodes[i].referralCode + ",";
      }
    } catch (e) {
      text = "Getting ref codes...";
    }

    return Text(text);
  }

  compareInputRefCode(String str) {
    String code = str.trim().toUpperCase();
    print(code);

    for (int i = 0; i < refCodes.length; i++) {
      if (refCodes[i].referralCode.compareTo(code) == 0) {
        print(refCodes[i].referralCode);
        print("matched");
        setState(() {
          isRefCodeAvailable = true;
          resultText = "Congratulations! Your referral code is applied.";
        });
        break;
      } else {
        print(refCodes[i].referralCode);
        print("not matched");
        setState(() {
          isRefCodeAvailable = false;
          resultText = "Oops! Your referral code is invalid.";
        });
      }
    }

    if (!isRefCodeAvailable) {
      refCodeController.text = "-";
    }
  }

  Padding buildFieldOfStudyField() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: TextFormField(
              style: TextStyle(fontFamily: fontName),
              controller: refCodeController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                hintStyle: TextStyle(fontFamily: fontName),
                border: OutlineInputBorder(),
                labelText: "Referral Code",
                labelStyle: TextStyle(fontFamily: fontName),
                hintText: "Input your referral code",
              ),
            ),
            trailing: GestureDetector(
              onTap: () {
                compareInputRefCode(
                    refCodeController.text.trim().toUpperCase());
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "REDEEM",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: fontName,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              resultText != "" ? resultText : '',
              style: TextStyle(
                color: isRefCodeAvailable ? Colors.blue : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            buildFieldOfStudyField(),
            buildRefCodes(),
          ],
        ),
      ),
    );
  }
}
