import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/models/article.dart';
import 'package:ybb/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    new MaterialApp(
      title: 'YBB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Colors.blue[200],
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyApp(),
    ),
  );
}

List<ArticleModel> articlesFromMain = [];

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    //loadNews();
  }

  loadNews() async {
    NewsData newsData = new NewsData();

    await newsData.getArticles();

    articlesFromMain = newsData.articles;
  }

  Future<Widget> loadFromFuture() async {
    NewsData newsData = new NewsData();

    await newsData.getArticles();

    articlesFromMain = newsData.articles;

    return Future.value(new Home());
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
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
}
