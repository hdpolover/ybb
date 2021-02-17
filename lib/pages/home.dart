import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/create_account.dart';
import 'package:ybb/pages/profile.dart';
import 'package:ybb/pages/search.dart';
import 'package:ybb/pages/timeline.dart';
import 'package:ybb/pages/news.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();

    if (!doc.exists) {
      // 3) get username from create account, use it to make new user document in users collection
      usersRef.doc(user.id).set(
        {
          "id": user.id,
          "username": getRandomUsername(user.id),
          "photoUrl": user.photoUrl,
          "email": user.email,
          "displayName": user.displayName,
          "bio": "",
          "timestamp": timestamp,
          "occupation": "",
          "interests": {}
        },
      );

      // 2) if the user doesn't exist, then we want to take them to the create account page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );

      // make new user their own follower (to include their posts in their timeline)
      await followersRef
          .doc(user.id)
          .collection('userFollowers')
          .doc(user.id)
          .set({});

      doc = await usersRef.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  String getRandomUsername(String id) {
    String username = "ybbuser";
    String number = id.substring(id.length - 6);
    return username + number;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          News(),
          Search(),
          ActivityFeed(currentUser: currentUser),
          //UploadPost(currentUser: currentUser),
          Profile(profileId: currentUser?.id, username: currentUser?.username),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.whatshot),
              label: "News",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Search",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
              label: "Activity",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ]),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/1.png'),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
              colors: [Colors.blue[300], Colors.blue],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter),
        ),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 200,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 40,
                  ),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 100,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage('assets/images/ybb_logo.png'),
                      height: 170,
                      width: 170,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Youth Break the Boundaries",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: ButtonTheme(
                    buttonColor: Colors.white,
                    minWidth: MediaQuery.of(context).size.width,
                    height: 55,
                    child: RaisedButton(
                      onPressed: login,
                      child: Text(
                        'Let\'s get started!',
                        style: TextStyle(color: Colors.blue, fontSize: 22),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    )),
              ),
            ],
          ),
        ),
      ),
    );

    // return Scaffold(
    //   body: Container(
    //     decoration: BoxDecoration(
    //       color: Theme.of(context).primaryColor,
    //     ),
    //     alignment: Alignment.center,
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: <Widget>[
    //         Text(
    //           'YBB',
    //           style: TextStyle(
    //             fontFamily: "Signatra",
    //             fontSize: 90.0,
    //             color: Colors.white,
    //           ),
    //         ),
    //         GestureDetector(
    //           onTap: login,
    //           child: Container(
    //             width: 260.0,
    //             height: 60.0,
    //             decoration: BoxDecoration(
    //               image: DecorationImage(
    //                 image: AssetImage(
    //                   'assets/images/google_signin_button.png',
    //                 ),
    //                 fit: BoxFit.cover,
    //               ),
    //             ),
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
