import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/summit_portal/summit_regist/register_4.dart';

class SummitRegister3 extends StatefulWidget {
  @override
  _SummitRegister3State createState() => _SummitRegister3State();
}

class _SummitRegister3State extends State<SummitRegister3> {
  TextEditingController essayController = TextEditingController();

  List _subthemes = [
    "Economy",
    "Education",
    "Public Policy",
    "Mental Health",
  ];

  List<DropdownMenuItem<String>> _subthemesDropdownItems;
  String subthemeValue;

  int progress;

  @override
  void initState() {
    super.initState();

    getProgress();
    _subthemesDropdownItems = getDropDownMenuItems(_subthemes);
  }

  getProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    essayController.text = prefs.getString("essay");

    setState(() {
      subthemeValue = prefs.getString("subtheme");
    });

    progress = prefs.getInt("filledCount");
  }

  saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("essay", essayController.text);
    prefs.setString("subtheme", subthemeValue);

    if (progress <= 6) {
      prefs.setInt("filledCount", 6);
    }
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List selected) {
    List<DropdownMenuItem<String>> items = new List();
    for (String x in selected) {
      items.add(new DropdownMenuItem(value: x, child: new Text(x)));
    }
    return items;
  }

  Padding buildEssayField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: essayController,
        minLines: 10,
        maxLines: 100,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Essay",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Write an essay of your chosen sub-theme.",
        ),
      ),
    );
  }

  Padding buildSubthemeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Sub-theme",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
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
                hint: Text("Select a sub-theme"),
                value: subthemeValue,
                items: _subthemesDropdownItems,
                onChanged: (value) {
                  setState(() {
                    subthemeValue = value;
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

  Padding buildIntroField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Essay",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            "(3/5)",
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
            buildSubthemeField(),
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
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text:
                        "Your essay length must be between 200 to 300 words. It is recommended that you write your essay on other platforms and paste it here.",
                    style: TextStyle(
                      fontFamily: fontName,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            buildEssayField(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            GestureDetector(
              onTap: () {
                saveProgress();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummitRegister4(),
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
