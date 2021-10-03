import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/helpers/curve_painter.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/post_detail.dart';
import 'package:ybb/pages/profile.dart';
import 'package:ybb/pages/search.dart';
import 'package:ybb/pages/create_account.dart';
import 'package:ybb/pages/summit_portal/sp_home.dart';
import 'package:ybb/pages/timeline.dart';
import 'package:ybb/widgets/dialog.dart';
import 'package:ybb/pages/news.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

final storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final feedbackRef = FirebaseFirestore.instance.collection('feedbacks');
final userRecomsRef =
    FirebaseFirestore.instance.collection('userRecommendations');
final messagesRef = FirebaseFirestore.instance.collection('messages');
final messageListsRef = FirebaseFirestore.instance.collection('messageLists');

//authentication
final GoogleSignIn googleSignIn = new GoogleSignIn();
FirebaseAuth _auth = FirebaseAuth.instance;
User firebaseUser;
AppUser currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  bool isNewUser;

  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  @override
  initState() {
    super.initState();
    // addNewFields();
    getUserStatusToApp();

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

  getUserStatusToApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool boolValue = prefs.getBool('isNew');
    setState(() {
      isNewUser = boolValue;
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
      configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  configurePushNotifications() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    GoogleSignInAuthentication googleSignInAuthentication =
        await user.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    var result = (await _auth.signInWithCredential(credential));

    firebaseUser = result.user;

    if (Platform.isIOS) getIOSPermission();

    _firebaseMessaging.getToken().then((token) {
      usersRef
          .doc(firebaseUser.uid)
          .update({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        final String recipientId = message['data']['recipient'];
        final String postId = message['data']['postId'];
        // final dynamic data = message['notification']['body'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => postId == null || postId.isEmpty
                ? Profile(
                    isFromOutside: true,
                    profileId: recipientId,
                  )
                : PostDetail(
                    userId: recipientId,
                  ),
          ),
        );
      },
      onResume: (Map<String, dynamic> message) async {
        //_showItemDialog(message);

        final String recipientId = message['data']['recipient'];
        final String postId = message['data']['postId'];
        // final dynamic data = message['notification']['body'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => postId == null || postId.isEmpty
                ? Profile(
                    isFromOutside: true,
                    profileId: recipientId,
                  )
                : PostDetail(
                    userId: recipientId,
                  ),
          ),
        );
      },
      onMessage: (Map<String, dynamic> message) async {
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];

        if (recipientId == firebaseUser.uid) {
          SnackBar snackBar = SnackBar(
              backgroundColor: Colors.blue,
              content: Text(
                body,
                overflow: TextOverflow.ellipsis,
              ));
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      },
    );
  }

  getIOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((event) {
      print("setting registred: $event");
    });
  }

  createUserInFirestore() async {
    Dialogs.showLoadingDialog(context, _keyLoader);

    GoogleSignInAccount user = googleSignIn.currentUser;
    GoogleSignInAuthentication googleSignInAuthentication =
        await user.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    var result = (await _auth.signInWithCredential(credential));

    firebaseUser = result.user;

    String name = "";

    // 1) check if user exists in users collection in database (according to their id)
    // final GoogleSignInAccount user = googleSignIn.currentUser;
    // DocumentSnapshot doc = await usersRef.doc(user.id).get();
    DocumentSnapshot doc = await usersRef.doc(firebaseUser.uid).get();

    //pop loading
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      print(e);
    }

    bool isRegistered = true;

    if (!doc.exists) {
      // 3) get username from create account, use it to make new user document in users collection
      usersRef.doc(firebaseUser.uid).set(
        {
          "id": firebaseUser.uid,
          "username": getRandomUsername(firebaseUser.uid),
          "photoUrl": firebaseUser.photoURL,
          "email": firebaseUser.email,
          "displayName": firebaseUser.displayName,
          "bio": "-",
          "registerDate": DateTime.now(),
          "occupation": "-",
          "interests": "-",
          "dnSearchKey": firebaseUser.displayName.substring(0, 1).toUpperCase(),
          "phoneNumber": "-",
          "instagram": "-",
          "facebook": "-",
          "website": "-",
          "showContacts": false,
          "mainInterest": "-",
          "mainOccupation": "-",
          "residence": "-",
          "birthdate": "-",
          "latitude": "-",
          "longitude": "-",
        },
      );

      name = firebaseUser.displayName;

      isRegistered = false;

      followersRef
          .doc(firebaseUser.uid)
          .collection('userFollowers')
          .doc(firebaseUser.uid)
          .set({});

      followersRef
          .doc("ynD3p86rqVc2mOIO83YOpXdWGtX2")
          .collection('userFollowers')
          .doc(firebaseUser.uid)
          .set({});

      followingRef
          .doc(firebaseUser.uid)
          .collection('userFollowing')
          .doc("ynD3p86rqVc2mOIO83YOpXdWGtX2")
          .set({});

      followingRef
          .doc(firebaseUser.uid)
          .collection('userFollowing')
          .doc(firebaseUser.uid)
          .set({});

      doc = await usersRef.doc(firebaseUser.uid).get();

      try {
        currentUser = AppUser.fromDocument(doc);
      } catch (e) {
        currentUser = AppUser(
          id: doc['id'],
          email: doc['email'],
          username: doc['username'],
          photoUrl: doc['photoUrl'],
          displayName: doc['displayName'],
          bio: doc['bio'],
          occupation: doc['occupation'],
          interests: doc['interests'],
          registerDate: doc['registerDate'].toDate(),
          phoneNumber: doc['phoneNumber'],
          showContacts: doc['showContacts'],
          instagram: doc['instagram'],
          facebook: doc['facebook'],
          website: doc['website'],
        );
      }

      SnackBar snackBar = SnackBar(
          backgroundColor: Colors.blue,
          content: Text("Registered! Welcome $name!"));
      _scaffoldKey.currentState.showSnackBar(snackBar);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(currentUserId: currentUser.id),
        ),
      );
    }

    try {
      currentUser = AppUser.fromDocument(doc);
    } catch (e) {
      currentUser = AppUser(
        id: doc['id'],
        email: doc['email'],
        username: doc['username'],
        photoUrl: doc['photoUrl'],
        displayName: doc['displayName'],
        bio: doc['bio'],
        occupation: doc['occupation'],
        interests: doc['interests'],
        registerDate: doc['registerDate'].toDate(),
        phoneNumber: doc['phoneNumber'],
        showContacts: doc['showContacts'],
        instagram: doc['instagram'],
        facebook: doc['facebook'],
        website: doc['website'],
      );
    }

    name = currentUser.displayName;

    if (isRegistered) {
      SnackBar snackBar = SnackBar(
          backgroundColor: Colors.blue, content: Text("Welcome back, $name!"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
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
    if (Platform.isIOS) {
    } else {
      googleSignIn.signIn();
    }

    addUserStatus();
  }

  addUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isNew', false);
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

  GlobalKey _bottomNavigationKey = GlobalKey();
  bool homeSelected = true;
  bool newsSelected = false;
  bool searchSelected = false;
  bool portalSelected = false;
  bool profileSelected = false;

  Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          News(),
          Search(),
          SPHome(),
          Profile(
            profileId: currentUser?.id,
            isFromOutside: false,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        onTap: (index) {
          onTap(index);
          setState(
            () {
              switch (index) {
                case 0:
                  homeSelected = true;
                  newsSelected = false;
                  searchSelected = false;
                  portalSelected = false;
                  profileSelected = false;
                  break;
                case 1:
                  homeSelected = false;
                  newsSelected = true;
                  searchSelected = false;
                  portalSelected = false;
                  profileSelected = false;
                  break;
                case 2:
                  homeSelected = false;
                  newsSelected = false;
                  searchSelected = true;
                  portalSelected = false;
                  profileSelected = false;
                  break;
                case 3:
                  homeSelected = false;
                  newsSelected = false;
                  searchSelected = false;
                  portalSelected = true;
                  profileSelected = false;
                  break;
                case 4:
                  homeSelected = false;
                  newsSelected = false;
                  searchSelected = false;
                  portalSelected = false;
                  profileSelected = true;
                  break;
                default:
                  homeSelected = true;
                  newsSelected = false;
                  searchSelected = false;
                  portalSelected = false;
                  profileSelected = false;
                  break;
              }
            },
          );
        },
        height: MediaQuery.of(context).size.height * 0.06,
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        key: _bottomNavigationKey,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 400),
        letIndexChange: (index) => true,
        items: [
          Icon(
            Icons.home,
            size: 25,
            color: homeSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          Icon(
            Icons.whatshot,
            size: 25,
            color: newsSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          Icon(
            Icons.search,
            size: 25,
            color:
                searchSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          Icon(
            //Icons.confirmation_num,
            Icons.local_play,
            size: 25,
            color:
                portalSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          Icon(
            Icons.account_circle,
            size: 25,
            color:
                profileSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: CustomPaint(
        painter: CurvePainter(),
        child: Center(
          child: Column(
            children: <Widget>[
              isNewUser == null
                  ? SizedBox(height: MediaQuery.of(context).size.height / 7)
                  : SizedBox(height: MediaQuery.of(context).size.height / 4),
              Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  isNewUser == null
                      ? "We're happy to have you here"
                      : 'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    height: 1.2,
                    fontFamily: fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.05,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 4),
              //SvgPicture.asset('assets/images/welcome.svg', height: 150),
              Image(
                image: AssetImage("assets/images/ybb_black_full.png"),
                height: MediaQuery.of(context).size.height * 0.13,
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 10),
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35, bottom: 40),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  padding: EdgeInsets.all(20),
                  color: Theme.of(context).primaryColor,
                  //onPressed: login,
                  onPressed: Platform.isIOS
                      ? () {
                          buildLoginOptions(context, _keyLoader);
                        }
                      : login,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "Let\'s get started!",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: fontName,
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

  loginWithApple() {
    return SignInWithAppleButton(
      onPressed: () async {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        print(credential);

        // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
        // after they have been validated with Apple (see `Integration` section for more information on how to do this)
      },
    );
  }

  buildLoginOptions(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (BuildContext context) {
        return SimpleDialog(
          key: key,
          elevation: 0,
          contentPadding: EdgeInsets.all(30),
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  Text(
                    "Create an account to start your journey with the Youth Break the Boundaries community.",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: fontName,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  SignInButton(
                    buttonType: ButtonType.google,
                    buttonSize: ButtonSize.large,
                    onPressed: () {
                      print('click');
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  SignInButton(
                    buttonType: ButtonType.apple,
                    buttonSize: ButtonSize.large,
                    onPressed: () async {
                      final credential =
                          await SignInWithApple.getAppleIDCredential(
                        scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ],
                      );

                      print(credential);

                      // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                      // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
