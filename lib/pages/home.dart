import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybb/helpers/curve_painter.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/create_account.dart';
import 'package:ybb/pages/profile.dart';
import 'package:ybb/pages/search.dart';
import 'package:ybb/pages/signup.dart';
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

  bool _showPassword = false;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

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
          "interests": "",
        },
      );

      // 2) if the user doesn't exist, then we want to take them to the create account page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(currentUserId: user.id),
        ),
      );

      // make new user their own follower (to include their posts in their timeline)
      await followersRef
          .doc(user.id)
          .collection('userFollowers')
          .doc(user.id)
          .set({});

      await followersRef
          .doc("104302720039797896575")
          .collection('userFollowers')
          .doc(user.id)
          .set({});

      await followingRef
          .doc(user.id)
          .collection('userFollowing')
          .doc("104302720039797896575")
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

  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomPaint(
        painter: CurvePainter(),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 250),
              Container(
                margin: EdgeInsets.only(left: 30),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
              SizedBox(height: 180),
              //SvgPicture.asset('assets/images/welcome.svg', height: 150),
              Image(
                image: AssetImage("assets/images/ybb_black_full.png"),
                height: 120,
              ),
              SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35, bottom: 40),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  padding: EdgeInsets.all(20),
                  color: Theme.of(context).primaryColor,
                  onPressed: login,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "Let\'s get started!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Scaffold buildUnAuthScreen() {
  //   return Scaffold(
  //     resizeToAvoidBottomInset: false,
  //     body: CustomPaint(
  //       painter: CurvePainter(),
  //       child: Center(
  //         child: Column(
  //           children: <Widget>[
  //             SizedBox(height: 80),
  //             Container(
  //               margin: EdgeInsets.only(left: 30),
  //               alignment: Alignment.centerLeft,
  //               child: Text(
  //                 'Welcome Back',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontFamily: "Montserrat",
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 35,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 30),
  //             SvgPicture.asset('assets/images/welcome.svg', height: 130),
  //             SizedBox(height: 10),
  //             Padding(
  //               padding: EdgeInsets.all(25),
  //               child: Column(
  //                 children: [
  //                   TextFormField(
  //                     keyboardType: TextInputType.emailAddress,
  //                     controller: _emailController,
  //                     decoration: InputDecoration(
  //                       border: OutlineInputBorder(),
  //                       labelText: "Email",
  //                     ),
  //                   ),
  //                   SizedBox(height: 15),
  //                   TextFormField(
  //                     controller: _passwordController,
  //                     obscureText: !_showPassword,
  //                     cursorColor: Colors.red,
  //                     decoration: InputDecoration(
  //                       labelText: "Password",
  //                       border: OutlineInputBorder(),
  //                       suffixIcon: GestureDetector(
  //                         onTap: () {
  //                           _togglevisibility();
  //                         },
  //                         child: Icon(
  //                           _showPassword
  //                               ? Icons.visibility
  //                               : Icons.visibility_off,
  //                           color: Colors.blue,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(left: 25, right: 25),
  //               child: ButtonTheme(
  //                   buttonColor: Theme.of(context).primaryColor,
  //                   minWidth: MediaQuery.of(context).size.width,
  //                   height: 50,
  //                   child: RaisedButton(
  //                       onPressed: login,
  //                       child: Text(
  //                         'Log in',
  //                         style: TextStyle(color: Colors.white, fontSize: 18),
  //                       ),
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(5)))),
  //             ),
  //             SizedBox(height: 20),
  //             Divider(
  //               indent: 20,
  //               endIndent: 20,
  //               thickness: 1,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
  //               child: Container(
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Text(
  //                       "Haven't registered yet?",
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         color: Colors.black,
  //                       ),
  //                     ),
  //                     GestureDetector(
  //                       onTap: () => Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => SignUp(),
  //                         ),
  //                       ),
  //                       child: Container(
  //                         child: Text(
  //                           " Register here",
  //                           style: TextStyle(
  //                             fontSize: 16,
  //                             color: Colors.blue,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Container(
  //               margin: EdgeInsets.only(bottom: 20, top: 20),
  //               child: Text(
  //                 "OR",
  //                 style: TextStyle(
  //                   color: Colors.black,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
  //               child: GestureDetector(
  //                 onTap: login,
  //                 child: Image(
  //                   image: AssetImage("assets/images/google_signin_button.png"),
  //                   height: 50,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
