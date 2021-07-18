import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/summit_portal/summit_regist/register_5.dart';

class SummitRegister4 extends StatefulWidget {
  @override
  _SummitRegister4State createState() => _SummitRegister4State();
}

class _SummitRegister4State extends State<SummitRegister4> {
  TextEditingController sourceNameController = TextEditingController();
  TextEditingController videoLinkController = TextEditingController();

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

  @override
  void initState() {
    super.initState();

    getProgress();

    _sourcesDropdownItems = getDropDownMenuItems(_sources);
  }

  getProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    sourceNameController.text = prefs.getString("source_account_name");
    setState(() {
      sourcesValue = prefs.getString("know_program_from");
    });
    videoLinkController.text = prefs.getString("video_link");

    progress = prefs.getInt("filledCount");
  }

  saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("source_account_name", sourceNameController.text);
    prefs.setString("know_program_from", sourcesValue);
    prefs.setString("video_link", videoLinkController.text);

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
            buildVideoLinkField(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            GestureDetector(
              onTap: () {
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
