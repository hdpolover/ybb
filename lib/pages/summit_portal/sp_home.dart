import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ybb/helpers/api/summit.dart';
import 'package:ybb/helpers/api/summit_participant.dart';
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

  buildSummitTile(String summitLogo, String imgUrl, Widget pageTo, int status) {
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

              await SummitParticipant.getParticipant(currentUser.id)
                  .then((value) {
                SummitParticipant p = value;
                setState(() {});

                if (p != null) {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PortalMain(participant: p),
                    ),
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
              });
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
            // Container(
            //   alignment: Alignment.center,
            //   height: MediaQuery.of(context).size.height * 0.10,
            //   width: MediaQuery.of(context).size.width * 0.45,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(6.0),
            //     color: status == 0 ? Colors.black38 : Colors.black12,
            //   ),
            //   padding: EdgeInsets.all(5),
            //   child: Text(
            //     summitName,
            //     style: TextStyle(
            //       color: status == 0 ? Colors.grey : Colors.white,
            //       fontSize: 15.0,
            //       fontWeight: FontWeight.bold,
            //       fontFamily: "OpenSans",
            //       letterSpacing: 1,
            //     ),
            //     softWrap: true,
            //     textAlign: TextAlign.center,
            //   ),
            // )
          ],
        ),
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

          // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          // Text(
          //   "Read more about the summits here",
          //   style: TextStyle(
          //     color: Colors.black,
          //     fontFamily: "OpenSans",
          //     fontSize: 15.0,
          //   ),
          //   textAlign: TextAlign.justify,
          // ),
          // SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          // Row(
          //   children: [
          //     buildSummitTile(
          //       "Istanbul Youth Summit 2022",
          //       "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
          //       IYSMain(),
          //     ),
          //     buildSummitTile(
          //       "Asia Youth Summit 2021",
          //       "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
          //       SPHome(),
          //     ),
          //   ],
          // ),
          // Row(
          //   children: [
          //     buildSummitTile(
          //       "DIgital Youth Summit",
          //       "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
          //       SPHome(),
          //     ),
          //     buildSummitTile(
          //       "Global Youth Ambassador",
          //       "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
          //       SPHome(),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
