import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybb/helpers/api/influencer.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/summit_portal/summit_regist/register_5.dart';

class SummitRegister4 extends StatefulWidget {
  @override
  _SummitRegister4State createState() => _SummitRegister4State();
}

class _SummitRegister4State extends State<SummitRegister4> {
  TextEditingController sourceNameController = TextEditingController();
  TextEditingController videoLinkController = TextEditingController();
  TextEditingController proofLinkController = TextEditingController();
  TextEditingController refCodeController = new TextEditingController();
  List<Influencer> refCodes = [];

  bool isRefCodeAvailable = false;
  String resultText = "";

  @override
  void dispose() {
    super.dispose();
    sourceNameController.dispose();
    videoLinkController.dispose();
    proofLinkController.dispose();
    refCodeController.dispose();
  }

  List _sources = [
    "Instagram",
    "WhatsApp",
    "Facebook",
    "Friends",
    "Others",
  ];

  List<DropdownMenuItem<String>> _sourcesDropdownItems;
  String sourcesValue;

  int progress;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();

    getProgress();
    getInfluencers();

    _sourcesDropdownItems = getDropDownMenuItems(_sources);
  }

  getProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    sourceNameController.text = prefs.getString("source_account_name");
    setState(() {
      sourcesValue = prefs.getString("know_program_from");
    });
    videoLinkController.text = prefs.getString("video_link");
    proofLinkController.text = prefs.getString("proof_link");
    refCodeController.text = prefs.getString("referral_code");

    progress = prefs.getInt("filledCount");
  }

  saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("source_account_name", sourceNameController.text);
    prefs.setString("know_program_from", sourcesValue);
    prefs.setString("video_link", videoLinkController.text);
    prefs.setString("proof_link", proofLinkController.text);
    prefs.setString(
        "referral_code", refCodeController.text.trim().toUpperCase());

    if (progress <= 8) {
      prefs.setInt("filledCount", 8);
    }
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List selected) {
    List<DropdownMenuItem<String>> items = new List();
    for (String x in selected) {
      items.add(new DropdownMenuItem(value: x, child: new Text(x)));
    }
    return items;
  }

  Padding buildSourceField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: sourceNameController,
        keyboardType: TextInputType.name,
        minLines: 1,
        maxLines: 2,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Source Account/Name",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Specify the account / name you got the info from",
        ),
      ),
    );
  }

  Padding buildKnowProgramFromField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "How do you know about this program?",
              softWrap: true,
              style: TextStyle(
                fontFamily: fontName,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                style: TextStyle(
                  fontFamily: fontName,
                  color: Colors.black,
                ),
                hint: Text("Select a source"),
                value: sourcesValue,
                items: _sourcesDropdownItems,
                onChanged: (value) {
                  setState(() {
                    sourcesValue = value;
                  });
                },
                elevation: 6,
                icon: Icon(
                  Icons.arrow_drop_down_circle,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildVideoLinkField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: videoLinkController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Motivation video Link",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input the link of your motivation video",
        ),
      ),
    );
  }

  Padding buildProofLinkField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: proofLinkController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Share Requirement Proof Link",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText:
              "Input the link to your Google Drive folder containing proofs (screenshots)",
        ),
      ),
    );
  }

  Padding buildIntroField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Program Information",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            "(4/5)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  getInfluencers() async {
    List<Influencer> p = await Influencer.getInfluencerRefCodes();

    setState(() {
      refCodes = p;
    });
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

  Column buildRefCodesField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.all(0),
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
              compareInputRefCode(refCodeController.text.trim().toUpperCase());
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
                    "APPLY",
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
        Text(
          resultText != "" ? resultText : '',
          style: TextStyle(
            color: isRefCodeAvailable ? Colors.blue : Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        saveProgress();

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              saveProgress();
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Registration Form",
            style: appBarTextStyle,
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.archive),
                onPressed: () {
                  saveProgress();

                  Fluttertoast.showToast(
                      msg: "Form drafted",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 1);

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }),
          ],
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          scrollDirection: Axis.vertical,
          children: [
            buildIntroField(),
            buildKnowProgramFromField(),
            buildSourceField(),
            RichText(
              softWrap: true,
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: fontName,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text:
                        "Paste the link to your motivation video about why you want to participate in the 5th Istanbul Youth Summit. The video can uploaded to Instagram or Youtube.",
                    style: TextStyle(
                      fontFamily: fontName,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            buildVideoLinkField(),
            RichText(
              softWrap: true,
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: fontName,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text:
                        "As mentioned on the Registration Guidelines, you need to do the followings: ",
                    style: TextStyle(
                      fontFamily: fontName,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: RichText(
                softWrap: true,
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: "- follow ",
                      style: TextStyle(
                        fontFamily: fontName,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "Istanbul Youth Summit ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: fontName,
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(
                      text: "and  ",
                      style: TextStyle(
                        fontFamily: fontName,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "Youth Break the Boundaries ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: fontName,
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(
                      text: "on Instagram.",
                      style: TextStyle(
                        fontFamily: fontName,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: RichText(
                softWrap: true,
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: "- tag 5 of your friends on your Instagram post.",
                      style: TextStyle(
                        fontFamily: fontName,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: RichText(
                softWrap: true,
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: "- share the event to 3 WhatsApp Groups",
                      style: TextStyle(
                        fontFamily: fontName,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RichText(
                softWrap: true,
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          "Take a screenshot of each of the actions above and upload them to your Google Drive. Copy the link and paste it in the input form below. (Make sure the folder is accessible by public)",
                      style: TextStyle(
                        fontFamily: fontName,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildProofLinkField(),
            RichText(
              softWrap: true,
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: fontName,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text:
                        "If you have the referral code of an IYS influencer, you can input it below. If not, just leave it empty.",
                    style: TextStyle(
                      fontFamily: fontName,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            buildRefCodesField(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            GestureDetector(
              onTap: () {
                saveProgress();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummitRegister5(),
                  ),
                );
              },
              child: Container(
                height: 50.0,
                width: 350.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Center(
                  child: Text(
                    "NEXT PAGE",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
