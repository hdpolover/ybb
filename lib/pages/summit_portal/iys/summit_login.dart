import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ybb/helpers/constants.dart';

class SummitLogin extends StatefulWidget {
  final String summitName;
  final String summitDesc;

  SummitLogin({
    @required this.summitName,
    @required this.summitDesc,
  });

  @override
  _SummitLoginState createState() => _SummitLoginState();
}

class _SummitLoginState extends State<SummitLogin> {
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();

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
      throw 'There was a problem to open the url: $url';
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
                  image: AssetImage("assets/images/portal.jpg"),
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
                    height: MediaQuery.of(context).size.height * 0.15,
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
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: Column(
                        children: [
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 0.0),
                              ),
                              border: const OutlineInputBorder(),
                              labelText: "Email",
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: password,
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 0.0),
                              ),
                              border: OutlineInputBorder(),
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 50.0,
                        width: 350.0,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Center(
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not a participant?",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "OpenSans",
                            fontSize: 13.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          " Be one by registering yourself",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "OpenSans",
                            fontSize: 13.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          " here.",
                          style: TextStyle(
                            color: Colors.blue,
                            fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
