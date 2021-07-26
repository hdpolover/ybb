import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ybb/helpers/api/summit_participant.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/summit_portal/pages/portal_main.dart';
import 'package:ybb/widgets/dialog.dart';

class SummitLogin extends StatefulWidget {
  final String summitName;
  final String summitDesc;
  final int summitId;

  SummitLogin({
    @required this.summitName,
    @required this.summitDesc,
    @required this.summitId,
  });

  @override
  _SummitLoginState createState() => _SummitLoginState();
}

class _SummitLoginState extends State<SummitLogin> {
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  final GlobalKey<State> _key = GlobalKey<State>();

  int summitId = 0;

  @override
  void initState() {
    super.initState();

    summitId = widget.summitId;
  }

  openInstagram() async {
    var url = widget.summitName == "Istanbul Youth Summit (IYS) 2022"
        ? "https://www.instagram.com/istanbulyouthsummit/"
        : widget.summitName == "Asia Youth Summit (AYS) 2021"
            ? "https://www.instagram.com/asiayouthsummit/"
            : "hdpolover";

    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'There was a problem to open the url: $url',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
      );
    }
  }

  openWeb() async {
    var url = widget.summitName == "Istanbul Youth Summit (IYS) 2022"
        ? 'https://www.iys.youthbreaktheboundaries.com/'
        : "https://www.iys.youthbreaktheboundaries.com/";

    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      throw 'There was a problem to open the url: $url';
    }
  }

  Future<void> showConfirmationDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Registration',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "OpenSans",
              letterSpacing: 1,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  'You are about to register to be the participant of this summit. Are you sure?',
                  style: TextStyle(
                    fontFamily: fontName,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.red,
              textColor: Colors.white,
              child: Text('Confirm'),
              onPressed: () async {
                Dialogs.showRegisterDialog(context, _key);
                //Navigator.of(context).pop();

                Map<String, dynamic> data = {
                  'id_participant': currentUser.id,
                  'id_summit': widget.summitId.toString(),
                  'email': currentUser.email,
                };

                await SummitParticipant.registerParticipant(data).then((value) {
                  //Navigator.of(context).pop();
                  SummitParticipant sp = value;

                  setState(() {});

                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context).pop();

                  Fluttertoast.showToast(
                    msg: "Welcome Summit Participant!",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 1,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PortalMain(
                        participant: sp,
                      ),
                    ),
                  );
                });
                // , onError: (e) {
                //   Navigator.of(context).pop();
                //   Fluttertoast.showToast(
                //     msg: "An error happened. Try again later.",
                //     toastLength: Toast.LENGTH_LONG,
                //     timeInSecForIosWeb: 1,
                //   );
                // })
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('Cancel'),
              onPressed: () {
                print('Confirmed');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/iys_regist.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Opacity(
              opacity: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
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
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * 0.05, 10, 20, 10),
                    child: Text(
                      widget.summitName,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "SFProText",
                        fontSize: 30.0,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                      softWrap: true,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      widget.summitDesc,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "OpenSans",
                        fontSize: 13.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.globe,
                              color: Colors.white,
                            ),
                            onPressed: () => openWeb()),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.instagram,
                            color: Colors.white,
                          ),
                          onPressed: () => openInstagram(),
                        ),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white,
                          ),
                          onPressed: () async =>
                              await launch("https://wa.me/$adminNumber?text="),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  // Padding(
                  //   padding: EdgeInsets.all(16.0),
                  //   child: Container(
                  //     child: Column(
                  //       children: [
                  //         TextFormField(
                  //           style: TextStyle(color: Colors.white),
                  //           controller: email,
                  //           keyboardType: TextInputType.emailAddress,
                  //           decoration: InputDecoration(
                  //             enabledBorder: const OutlineInputBorder(
                  //               borderSide: const BorderSide(
                  //                   color: Colors.white, width: 0.0),
                  //             ),
                  //             border: const OutlineInputBorder(),
                  //             labelText: "Email",
                  //             labelStyle: TextStyle(color: Colors.white),
                  //           ),
                  //         ),
                  //         SizedBox(height: 15),
                  //         TextFormField(
                  //           style: TextStyle(color: Colors.white),
                  //           controller: password,
                  //           obscureText: true,
                  //           keyboardType: TextInputType.visiblePassword,
                  //           decoration: InputDecoration(
                  //             enabledBorder: const OutlineInputBorder(
                  //               borderSide: const BorderSide(
                  //                   color: Colors.white, width: 0.0),
                  //             ),
                  //             border: OutlineInputBorder(),
                  //             labelText: "Password",
                  //             labelStyle: TextStyle(color: Colors.white),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15),
                    child: GestureDetector(
                      onTap: () {
                        showConfirmationDialog(context);
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
                            "REGISTER YOURSELF",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 20),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => SummitRegister(),
                  //       ),
                  //     );
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(20.0),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Text(
                  //           "Not a participant?",
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontFamily: "OpenSans",
                  //             fontSize: 13.0,
                  //           ),
                  //           textAlign: TextAlign.left,
                  //         ),
                  //         Text(
                  //           " Be one by registering yourself",
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontFamily: "OpenSans",
                  //             fontSize: 13.0,
                  //           ),
                  //           textAlign: TextAlign.left,
                  //         ),
                  //         Text(
                  //           " here.",
                  //           style: TextStyle(
                  //             color: Colors.blue,
                  //             fontFamily: "OpenSans",
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 13.0,
                  //           ),
                  //           textAlign: TextAlign.left,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
