import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/summit_portal/iys/iys_main.dart';
import 'package:ybb/pages/summit_portal/summit_login.dart';
import 'package:ybb/widgets/default_appbar.dart';

class SPHome extends StatefulWidget {
  SPHome({Key key}) : super(key: key);

  @override
  _SPHomeState createState() => _SPHomeState();
}

class _SPHomeState extends State<SPHome> {
  buildSummitTile(String summitName, String imgUrl, Widget pageTo) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => pageTo,
        ),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.10,
                  fit: BoxFit.cover,
                  imageUrl: imgUrl),
            ),
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.10,
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: Colors.black12,
              ),
              padding: EdgeInsets.all(5),
              child: Text(
                summitName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "OpenSans",
                  letterSpacing: 1,
                ),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: defaultAppBar(context,
      //     titleText: "Summit Portal", removeBackButton: true),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/portal.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Opacity(
                opacity: 1,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).size.height * 0.06,
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
                      height: MediaQuery.of(context).size.height * 0.07,
                    ),
                    Text(
                      "Summit Portal",
                      style: appBarTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
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
                    Row(
                      children: [
                        buildSummitTile(
                          "Istanbul Youth Summit (IYS) 2022",
                          "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
                          SummitLogin(
                            summitName: "Istanbul Youth Summit (IYS) 2022",
                            summitDesc:
                                "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
                          ),
                        ),
                        buildSummitTile(
                          "Asia Youth Summit 2021",
                          "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
                          SummitLogin(
                            summitName: "Asia Youth Summit (AYS) 2021",
                            summitDesc:
                                "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        buildSummitTile(
                          "Digital Youth Summit",
                          "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
                          SummitLogin(
                            summitName: "Digital Youth Summit (DGS)",
                            summitDesc:
                                "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
                          ),
                        ),
                        buildSummitTile(
                          "Global Youth Ambassador",
                          "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
                          SummitLogin(
                            summitName: "Global Youth Ambassador (GYA)",
                            summitDesc:
                                "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
                          ),
                        ),
                      ],
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
