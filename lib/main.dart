import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/models/article.dart';
import 'package:ybb/pages/home.dart';
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

  @override
  void initState() {
    super.initState();

    checkConnection();
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

  Future<Widget> loadFromFuture() async {
    NewsData newsData = new NewsData();

    await newsData.getArticles();

    articlesFromMain = newsData.articles;

    return Future.value(new Home());
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: ConnectivityScreenWrapper(
    //     child: SafeArea(
    //       child: ConnectivityWidgetWrapper(
    //         stacked: false,
    //         offlineWidget: CustomSplashscreen(
    //           seconds: 1000,
    //           image:
    //               Image(image: AssetImage('assets/images/ybb_black_full.png')),
    //           backgroundColor: Colors.white,
    //           styleTextUnderTheLoader: new TextStyle(),
    //           photoSize: MediaQuery.of(context).size.width * 0.35,
    //           useLoader: true,
    //           loaderColor: Theme.of(context).primaryColor,
    //         ),
    //         child: CustomSplashscreen(
    //           onClick: loadFromFuture,
    //           seconds: 3,
    //           navigateAfterSeconds: new Home(),
    //           navigateAfterFuture: loadFromFuture(),
    //           image:
    //               Image(image: AssetImage('assets/images/ybb_black_full.png')),
    //           backgroundColor: Colors.white,
    //           styleTextUnderTheLoader: new TextStyle(),
    //           photoSize: MediaQuery.of(context).size.width * 0.35,
    //           useLoader: true,
    //           loaderColor: Theme.of(context).primaryColor,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return isConnected
        ? CustomSplashscreen(
            seconds: 3,
            navigateAfterSeconds: new Home(),
            navigateAfterFuture: loadFromFuture(),
            image: Image(image: AssetImage('assets/images/ybb_black_full.png')),
            backgroundColor: Colors.white,
            styleTextUnderTheLoader: new TextStyle(),
            photoSize: MediaQuery.of(context).size.width * 0.35,
            useLoader: true,
            loaderColor: Theme.of(context).primaryColor,
          )
        : NoInternet(isConnected: false);
  }
}
