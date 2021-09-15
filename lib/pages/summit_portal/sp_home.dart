import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ybb/helpers/api/summit.dart';
import 'package:ybb/helpers/api/summit_participant.dart';
import 'package:ybb/helpers/api/summit_timeline.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/summit_portal/pages/portal_main.dart';
import 'package:ybb/pages/summit_portal/summit_login.dart';
import 'package:ybb/widgets/dialog.dart';

class SPHome extends StatefulWidget {
  SPHome({Key key}) : super(key: key);

  @override
  _SPHomeState createState() => _SPHomeState();
}

class _SPHomeState extends State<SPHome> {
  final GlobalKey<State> key = GlobalKey<State>();
  @override
  void initState() {
    super.initState();
  }

  checkRegist() async {
    SummitTimeline st = await SummitTimeline.getTimelinebyId("1");
    DateTime current = new DateTime.now();
    bool isRegistrationPassed = st.endTimeline.isBefore(current);
    return isRegistrationPassed;
  }

  buildSummitTile(String summitLogo, String imgUrl, Widget pageTo, int status,
      int registStatus) {
    return GestureDetector(
      onTap: status == 0
          ? () {
              Fluttertoast.showToast(
                msg: "Coming soon!",
                timeInSecForIosWeb: 1,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          : () async {
              Dialogs.showLoadingDialog(context, key);

              SummitParticipant p =
                  await SummitParticipant.getParticipant(currentUser.id);

              if (p != null) {
                if (p.status == 0 && registStatus == 0) {
                  Navigator.of(context, rootNavigator: true).pop();
                  Fluttertoast.showToast(
                    msg:
                        "Apologies. Seems like the registration is already closed!",
                    timeInSecForIosWeb: 1,
                    toastLength: Toast.LENGTH_LONG,
                  );
                } else {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PortalMain(participant: p),
                    ),
                  );
                }
              } else {
                if (registStatus == 0) {
                  Navigator.of(context, rootNavigator: true).pop();
                  Fluttertoast.showToast(
                    msg:
                        "Apologies. Seems like the registration is already closed!",
                    timeInSecForIosWeb: 1,
                    toastLength: Toast.LENGTH_LONG,
                  );
                } else {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageTo,
                    ),
                  );
                }
              }
            },
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/" + imgUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height * 0.10,
                color: Colors.black45,
              ),
            ),
            summitLogo == "soon_text.png"
                ? Container(
                    margin: EdgeInsets.only(left: 25),
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.height * 0.10,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/" + summitLogo),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(left: 10),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.10,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/" + summitLogo),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
            status == 0
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.height * 0.10,
                      color: Colors.black45,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  buildError() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/no_internet.svg',
            height: MediaQuery.of(context).size.width * 0.35,
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
              ),
              child: Text(
                "We are sorry. It seems like the web is down. Please try again later.",
                style: TextStyle(
                  fontFamily: fontName,
                  fontSize: 16,
                ),
              ),
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
        toolbarHeight: 0,
        backgroundColor: Colors.blue,
        brightness: Brightness.light,
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/summit_portal.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).size.height * 0.07,
                color: Colors.black54,
              ),
              Opacity(
                opacity: 1,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).size.height * 0.07,
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.white12,
                        Colors.blue,
                      ],
                      stops: [
                        0.2,
                        1,
                        0.1,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Text(
                      "Summit Portal",
                      style: appBarTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height * 0.18,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/ybb_mix_full.png"),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "OpenSans",
                          fontSize: 13.0,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    FutureBuilder(
                      future: Summit.getSummits(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.1),
                            child: CircularProgressIndicator(),
                          );
                        }

                        List<Summit> summits = snapshot.data;

                        return Column(
                          children: [
                            Row(
                              children: [
                                buildSummitTile(
                                  "iys_logo.png",
                                  "iys_bg.jpg",
                                  SummitLogin(
                                    summitName: summits[0].desc,
                                    summitDesc:
                                        "The 5th Istanbul Youth Summit (IYS) is an International Summit organized by Youth Break the Boundaries (YBB) foundation in Istanbul, Turkey. This summit is initiated to encourage future leaders who can break the boundaries of their abilities to discuss and take action with the theme of “Development Responses Plan of The Youth in Crisis Recovery”.",
                                    summitId: int.parse(summits[0].summitId),
                                  ),
                                  summits[0].status,
                                  summits[0].registStatus,
                                ),
                                buildSummitTile(
                                  "ays_logo.png",
                                  "ays_bg.jpg",
                                  SummitLogin(
                                    summitName: summits[1].desc,
                                    summitDesc:
                                        "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
                                    summitId: int.parse(summits[1].summitId),
                                  ),
                                  summits[1].status,
                                  summits[1].registStatus,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                buildSummitTile(
                                  "gya_logo.png",
                                  "gya_bg.jpg",
                                  SummitLogin(
                                    summitName: summits[2].desc,
                                    summitDesc:
                                        "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
                                    summitId: int.parse(summits[2].summitId),
                                  ),
                                  summits[2].status,
                                  summits[2].registStatus,
                                ),
                                buildSummitTile(
                                  "soon_text.png",
                                  "soon_bg.jpg",
                                  SummitLogin(
                                    summitName: summits[3].desc,
                                    summitDesc:
                                        "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
                                    summitId: int.parse(summits[3].summitId),
                                  ),
                                  summits[3].status,
                                  summits[3].registStatus,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
