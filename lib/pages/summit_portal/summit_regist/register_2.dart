import 'package:flutter/material.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/summit_portal/summit_regist/register_3.dart';

class SummitRegister2 extends StatefulWidget {
  @override
  _SummitRegister2State createState() => _SummitRegister2State();
}

class _SummitRegister2State extends State<SummitRegister2>
    with AutomaticKeepAliveClientMixin<SummitRegister2> {
  TextEditingController experiencesController = TextEditingController();
  TextEditingController achievementsController = TextEditingController();
  TextEditingController socialProjectsController = TextEditingController();
  TextEditingController talentsController = TextEditingController();

  Padding buildExperiencesField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: experiencesController,
        minLines: 5,
        maxLines: 10,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Experiences",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText:
              "Any unforgettable experiences you have. Input (-) if none.",
        ),
      ),
    );
  }

  Padding buildTalentsField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        minLines: 3,
        maxLines: 10,
        controller: talentsController,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Talents",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Any talents you have. Input (-) if none.",
        ),
      ),
    );
  }

  Padding buildAchievementField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: achievementsController,
        minLines: 3,
        maxLines: 10,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Achievements",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText:
              "Any academic/non-academic achievements you have. Input (-) if none.",
        ),
      ),
    );
  }

  Padding buildSocialProjectsField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: socialProjectsController,
        minLines: 3,
        maxLines: 10,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Social Projects",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText:
              "Any social projects you have worked / are working on. Input (-) if none.",
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
            "Other Information",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            "(2/4)",
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Register",
          style: appBarTextStyle,
        ),
        actions: [
          IconButton(icon: Icon(Icons.archive), onPressed: () {}),
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
          buildExperiencesField(),
          buildAchievementField(),
          buildSocialProjectsField(),
          buildTalentsField(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SummitRegister3(),
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
    );
  }

  bool get wantKeepAlive => true;
}
