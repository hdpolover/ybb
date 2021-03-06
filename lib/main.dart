import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/models/article.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/trial.dart';
import 'package:ybb/widgets/custom_splashscreen.dart';
import 'package:ybb/widgets/no_internet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ConnectivityAppWrapper(
      app: MaterialApp(
        title: 'YBB',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColor: Colors.blue[200],
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyApp(),
      ),
    ),
  );
}

List<ArticleModel> articlesFromMain = [];

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isConnected = true;
  Future<dynamic> longLoad;

  @override
  void initState() {
    super.initState();

    checkConnection();
    countLoading();
    getNews();
  }

  checkConnection() async {
    if (await ConnectivityWrapper.instance.isConnected) {
      setState(() {
        isConnected = true;
      });
    } else {
      setState(() {
        isConnected = false;
      });
    }
  }

  Future<void> getNews() async {
    NewsData newsData = new NewsData();

    List<ArticleModel> a;
    try {
      a = await newsData.getArcs();
    } catch (e) {
      return articlesFromMain;
    }

    articlesFromMain = a;
  }

  Future<Widget> loadFromFuture() async {
    NewsData newsData = new NewsData();

    try {
      await newsData.getArticles();
    } catch (e) {
      print(e);
      articlesFromMain = [];
    }

    articlesFromMain = newsData.articles;

    return Future.value(new Home());
  }

  countLoading() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      longLoad = Future.value("This is taking longer than usual...");
    });
  }

  @override
  Widget build(BuildContext context) {
    return isConnected
        ? CustomSplashscreen(
            seconds: 3,
            navigateAfterSeconds: new Home(),
            //navigateAfterFuture: loadFromFuture(),
            image: Image(image: AssetImage('assets/images/ybb_black_full.png')),
            backgroundColor: Colors.white,
            styleTextUnderTheLoader: new TextStyle(),
            photoSize: MediaQuery.of(context).size.width * 0.35,
            useLoader: true,
            loaderColor: Theme.of(context).primaryColor,
            loadingText: FutureBuilder(
              future: longLoad,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("");
                }
                return Text(
                  snapshot.data,
                  style: TextStyle(
                    fontFamily: fontName,
                    color: Colors.black,
                  ),
                );
              },
            ),
          )
        : NoInternet(isConnected: false);
  }
}
