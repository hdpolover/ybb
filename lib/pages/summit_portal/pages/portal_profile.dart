import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ybb/helpers/api/summit_participant.dart';
import 'package:ybb/helpers/api/summit_participant_details.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/summit_portal/pages/view_participant_detail.dart';
import 'package:ybb/pages/summit_portal/pages/document_center.dart';
import 'package:ybb/pages/summit_portal/summit_regist/register_1.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/dialog.dart';
import 'package:ybb/widgets/shimmers/summit_profile_shimmer_layout.dart';
import 'package:http/http.dart' as http;

class PortalProfile extends StatefulWidget {
  @override
  _PortalProfileState createState() => _PortalProfileState();
}

class _PortalProfileState extends State<PortalProfile>
    with AutomaticKeepAliveClientMixin<PortalProfile> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  int formCount = 10;

  List<String> status = [
    "Waiting for form completion",
    "Waiting for registration fee payment",
    "Registered",
    "Paid 1st payment batch",
    "Paid 2nd payment batch",
  ];

  String noteText =
      "In order to proceed with the summit program, you need to complete the registration form. Unless you do it, you will not be able to access all the features of Summit Portal and not be notified for the summit info and activities.";

  String info =
      "There are 5 sections of forms that you need to fill out. However you can always take a break and continue filling out the form another time if need be. Do that by clicking the icon on the AppBar.";

  final GlobalKey<State> _key = GlobalKey<State>();

  SummitParticipant sp;
  SummitParticipantDetails spd;

  @override
  void initState() {
    super.initState();
  }

  getCompletionProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int count = prefs.getInt('filledCount') ?? 0;

    double progress = count / formCount;
    print(progress.toString());

    return progress;
  }

  buildCompleteFormInfo() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Container(
        child: Column(
          children: [
            Text(
              "Important!",
              style: TextStyle(
                fontFamily: fontName,
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 15),
            Text(
              noteText,
              softWrap: true,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontFamily: fontName,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 15),
            Text(
              info,
              softWrap: true,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontFamily: fontName,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: getCompletionProgress(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                double res = snapshot.data;
                double viewPercent = snapshot.data * formCount * formCount;

                return Padding(
                  padding: EdgeInsets.all(15.0),
                  child: LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width * 0.7,
                    lineHeight: 25.0,
                    percent: res,
                    center: Text(
                      viewPercent.toString() + "% Completion",
                      style: TextStyle(fontSize: 12.0),
                    ),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                  ),
                );
              },
            ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummitRegister1(),
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
                    "COMPLETE REGISTRATION",
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

  buildProfileChip(SummitParticipant _sp) {
    String statusDesc = "";
    Color chipColor;

    switch (_sp.status) {
      case 0:
        statusDesc = status[0];
        chipColor = Colors.red;
        break;
      case 1:
        statusDesc = status[1];
        chipColor = Colors.red;
        break;
      case 2:
        statusDesc = status[2];
        chipColor = Colors.green;
        break;
      case 3:
        statusDesc = status[3];
        chipColor = Colors.blue;
        break;
      case 4:
        statusDesc = status[4];
        chipColor = Colors.blue;
        break;
    }

    return Chip(
      elevation: 0,
      padding: EdgeInsets.all(10),
      backgroundColor: chipColor,
      avatar: Icon(
        Icons.access_alarm,
        color: Colors.white,
        size: 17,
      ), //CircleAvatar
      label: Text(
        statusDesc,
        style: TextStyle(
          fontFamily: "SFProText",
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ), //Text
    );
  }

  Future<Null> refreshProfile() async {
    refreshkey.currentState?.show(atTop: true);

    setState(() {
      sp = null;
      spd = null;
    });

    await buildProfile();
  }

  buildNewParticipant() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return ListView(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(
            width * 0.2,
            30,
            width * 0.2,
            20,
          ),
          height: height * 0.3,
          width: width * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              image: AssetImage('assets/images/default_photo.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Chip(
          elevation: 0,
          padding: EdgeInsets.all(10),
          backgroundColor: Colors.red,
          avatar: Icon(
            Icons.access_alarm,
            color: Colors.white,
            size: 17,
          ), //CircleAvatar
          label: Text(
            status[0],
            style: TextStyle(
              fontFamily: "SFProText",
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ), //Text
        ),
        buildCompleteFormInfo(),
      ],
    );
  }

  buildParticipantComplete() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return FutureBuilder(
      future: SummitParticipantDetails.getParticipantDetails(currentUser.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SummitProfileShimmer();
        }

        spd = snapshot.data;

        String url = baseUrl + '/assets/img/profile/participants/' + spd.photo;

        return ListView(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(
                width * 0.2,
                30,
                width * 0.2,
                20,
              ),
              height: height * 0.3,
              width: width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                spd.fullName.toUpperCase(),
                style: commonTitleText,
              ),
            ),
            SizedBox(height: 20),
            buildProfileChip(sp),
            SizedBox(height: 20),
            buildParticipantDetails(spd),
            SizedBox(height: 30),
            buildFooter(),
          ],
        );
      },
    );
  }

  buildFooter() {
    return Container(
      child: Column(
        children: [
          Text(
            "\u00a9 The 5th Istanbul Youth Summit",
            style: TextStyle(
              fontWeight: FontWeight.w200,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.globe,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => openWeb(),
              ),
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.instagram,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => openInstagram(),
              ),
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => openFacebook(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildProfile() {
    return FutureBuilder(
      future: SummitParticipant.getParticipant(currentUser.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SummitProfileShimmer();
        }

        sp = snapshot.data;

        if (sp.status == 0) {
          return buildNewParticipant();
        } else {
          return buildParticipantComplete();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Participant Profile", removeBackButton: true),
      body: LiquidPullToRefresh(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.blue,
        animSpeedFactor: 2.5,
        backgroundColor: Colors.white,
        showChildOpacityTransition: false,
        key: refreshkey,
        onRefresh: refreshProfile,
        child: buildProfile(),
      ),
    );
  }

  buildParticipantDetails(SummitParticipantDetails data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: FlatButton(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(Icons.qr_code_outlined),
                    SizedBox(width: 10),
                    Text(
                      "Show QR Code",
                      style: TextStyle(fontFamily: fontName),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                Dialogs.showParticipantQrCode(context, _key, currentUser.id);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: FlatButton(
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text(
                      "View Participant Details",
                      style: TextStyle(fontFamily: fontName),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewParticipantDetails(data: data),
                  ),
                );
              },
            ),
          ),
          sp.status >= 2
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: FlatButton(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.folderOpen),
                          SizedBox(width: 10),
                          Text(
                            "Document Center",
                            style: TextStyle(fontFamily: fontName),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      generateLoa();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentCenter(),
                        ),
                      );
                    },
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: FlatButton(
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.whatsapp),
                    SizedBox(width: 10),
                    Text(
                      "Contact Admin",
                      style: TextStyle(fontFamily: fontName),
                    ),
                  ],
                ),
              ),
              onPressed: () async =>
                  await launch("https://wa.me/$adminNumber?text="),
            ),
          ),
        ],
      ),
    );
  }

  generateLoa() async {
    String url =
        baseUrl + "/api/doc_management/?id_participant=" + currentUser.id;

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      return jsonData;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  openInstagram() async {
    var url = "https://www.instagram.com/istanbulyouthsummit/";

    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      Fluttertoast.showToast(
          msg: 'There was a problem to open the url: $url',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  openFacebook() async {
    var url = "https://www.facebook.com/Istanbulyouthsummit/";

    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      Fluttertoast.showToast(
          msg: 'There was a problem to open the url: $url',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  openWeb() async {
    var url = "https://www.iys.youthbreaktheboundaries.com/";

    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      Fluttertoast.showToast(
          msg: 'There was a problem to open the url: $url',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  bool get wantKeepAlive => true;
}
