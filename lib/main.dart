import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/helpers/fcm_item.dart';
import 'package:ybb/models/article.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/custom_splashscreen.dart';
import 'package:ybb/widgets/no_internet.dart';
import 'package:ybb/pages/onboarding_screen.dart';

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

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  final String itemId = data['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(postId: itemId))
    ..status = data['status'];
  return item;
}

List<ArticleModel> articlesFromMain = [];
bool isNewUser;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isConnected = true;
  Future<dynamic> longLoad;

  String _homeScreenText = "Waiting for token...";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      content: Text("Item ${item.postId} has been updated"),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserStatusToApp();

    //initFcm();

    checkConnection();
    countLoading();
    getNews();
  }

  getUserStatusToApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool boolValue = prefs.getBool('isNew');
    setState(() {
      isNewUser = boolValue;
    });
  }

  initFcm() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });
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
            seconds: 2,
            navigateAfterSeconds:
                isNewUser == null ? new OnboardingScreen() : new Home(),
            //navigateAfterFuture: loadFromFuture(),
            image: Image(image: AssetImage('assets/images/ybb_black_full.png')),
            backgroundColor: Colors.white,
            styleTextUnderTheLoader: new TextStyle(),
            photoSize: MediaQuery.of(context).size.width * 0.35,
            useLoader: false,
            loaderColor: Theme.of(context).primaryColor,
            // loadingText: FutureBuilder(
            //   future: longLoad,
            //   builder: (context, snapshot) {
            //     if (!snapshot.hasData) {
            //       return Text("");
            //     }
            //     return Text(
            //       snapshot.data,
            //       style: TextStyle(
            //         fontFamily: fontName,
            //         color: Colors.black,
            //       ),
            //     );
            //   },
            // ),
          )
        : NoInternet(isConnected: false);
  }
}
