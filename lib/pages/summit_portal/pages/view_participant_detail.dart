import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ybb/helpers/api/summit_participant_details.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/widgets/default_appbar.dart';

class ViewParticipantDetails extends StatefulWidget {
  final SummitParticipantDetails data;

  ViewParticipantDetails({@required this.data});

  @override
  _ViewParticipantDetailsState createState() => _ViewParticipantDetailsState();
}

class _ViewParticipantDetailsState extends State<ViewParticipantDetails> {
  SummitParticipantDetails spd;

  TextStyle titleStyle = new TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  TextStyle contentStyle = new TextStyle(
    fontFamily: fontName,
    letterSpacing: 0.7,
  );

  @override
  void initState() {
    super.initState();
    spd = widget.data;
  }

  buildDetails() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Text(
          "Basic Information",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 10),
        buildHorizontalField("Full Name", spd.fullName),
        buildHorizontalField("Gender", spd.gender),
        buildHorizontalField("Birth date", spd.birthdate),
        buildHorizontalField("Address", spd.address),
        buildHorizontalField("Nationality", spd.nationality),
        buildHorizontalField("Occupation", spd.occupation),
        buildHorizontalField("Field of Study", spd.fieldOfStudy),
        buildHorizontalField("Occupation", spd.institution),
        buildHorizontalField("WhatsApp Number", spd.waNumber),
        buildHorizontalField("Emergency Contact", spd.emergencyContact),
        buildHorizontalField("Contact Relation", spd.contactRelation),
        buildHorizontalField("Instagram Account", "@" + spd.igAccount),
        buildHorizontalField(
            "Vegetarian", spd.isVegetarian == 0 ? "No" : "Yes"),
        buildHorizontalField("Occupation", spd.occupation),
        buildLinkField("Motivation Video Link", spd.videoLink),
        SizedBox(height: 30),
        Text(
          "Others",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 10),
        buildHorizontalField("Subtheme", spd.subtheme),
        buildVerticalField("Essay", spd.essay),
        buildVerticalField("Experiences", spd.experience),
        buildVerticalField("Achievements", spd.achievements),
        buildVerticalField("Talents", spd.talents),
        buildVerticalField("Social Projects", spd.socialProjects),
      ],
    );
  }

  buildLinkField(String title, String url) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 10),
          child: GestureDetector(
            onTap: () {
              openBrowser(url);
            },
            child: Text(url,
                textAlign: TextAlign.justify,
                softWrap: true,
                style: TextStyle(
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                )),
          ),
        ),
      ],
    );
  }

  openBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: "Error! Cannot launch link.",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  buildHorizontalField(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Text(
            content,
            textAlign: TextAlign.justify,
            softWrap: true,
            style: contentStyle,
          ),
        ],
      ),
    );
  }

  buildVerticalField(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 10),
            child: Text(
              content,
              textAlign: TextAlign.justify,
              softWrap: true,
              style: contentStyle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Participant Details", removeBackButton: false),
      body: buildDetails(),
    );
  }
}
