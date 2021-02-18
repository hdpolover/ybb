import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/models/article_model.dart';
import 'package:ybb/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    new MaterialApp(
      title: 'YBB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Colors.blue[900],
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
      // title: new Text(
      //   'Youth Break the Boundaries',
      //   style: new TextStyle(
      //     fontWeight: FontWeight.bold,
      //     fontSize: 20.0,
      //     color: Colors.black,
      //   ),
      // ),
      image: Image(image: AssetImage('assets/images/ybb_logo.png')),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      loaderColor: Theme.of(context).primaryColor,
      loadingText: Text("Fetching data..."),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'YBB',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         accentColor: Colors.blue[900],
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: AnimatedSplashScreen(
//         splash: Image.asset('assets/images/ybb_logo.png'),
//         nextScreen: Home(),
//       ),
//     );
//   }
// }
