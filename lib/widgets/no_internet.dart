import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/main.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/custom_splashscreen.dart';

class NoInternet extends StatefulWidget {
  final bool isConnected;

  NoInternet({this.isConnected});

  @override
  _NoInternetState createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isConnected = false;

  @override
  void initState() {
    super.initState();

    isConnected = widget.isConnected;
  }

  Future<Widget> loadFromFuture() async {
    NewsData newsData = new NewsData();

    await newsData.getArticles();

    articlesFromMain = newsData.articles;

    return Future.value(new Home());
  }

  tryAgain() {
    return CustomSplashscreen(
      seconds: 3,
      navigateAfterSeconds: new Home(),
      navigateAfterFuture: loadFromFuture(),
      image: Image(image: AssetImage('assets/images/ybb_black_full.png')),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: MediaQuery.of(context).size.width * 0.35,
      useLoader: true,
      loaderColor: Theme.of(context).primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: isConnected
            ? tryAgain()
            : Container(
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
                          "Oops! It seems like you are offline. Try connecting to a network.",
                          style: TextStyle(
                            fontFamily: fontName,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ConnectivityWidgetWrapper(
                      child: FlatButton(
                        textColor: Colors.blue,
                        color: Colors.white10,
                        onPressed: () {
                          setState(() {
                            isConnected = true;
                          });
                        },
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                              fontFamily: fontName,
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
