import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'home.dart';

class SignUp extends StatefulWidget {
  final String currentUserId;

  SignUp({this.currentUserId});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController email = new TextEditingController();
  TextEditingController displayName = new TextEditingController();
  TextEditingController occupation = new TextEditingController();
  TextEditingController interests = new TextEditingController();
  TextEditingController bio = new TextEditingController();

  bool _occupation = true;
  bool _interests = true;
  bool _bio = true;

  List<String> inters;

  updateProfileData() {
    setState(() {
      occupation.text.trim().length < 3 || occupation.text.trim().isEmpty
          ? _occupation = false
          : _occupation = true;

      interests.text.trim().length < 3 || interests.text.trim().isEmpty
          ? _interests = false
          : _interests = true;

      bio.text.trim().length > 50 ? _bio = false : _bio = true;
    });

    if (_occupation && _interests && _bio) {
      usersRef.doc(widget.currentUserId).update({
        "occupation": occupation.text,
        "interests": interests.text,
        "bio": bio.text,
      });

      SnackBar snackBar =
          SnackBar(content: Text("Profile successfully updated!"));
      _scaffoldKey.currentState.showSnackBar(snackBar);

      //Navigator.pop(context);
      Timer(
        Duration(seconds: 2),
        () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      SnackBar snackbar = SnackBar(content: Text("Welcome!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);

      Timer(
        Duration(seconds: 2),
        () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        //appBar: defaultAppBar(context, titleText: "User Details", removeBackButton: true),
        body: ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Center(
                      child: Text(
                        "Let others know you by completing these",
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Montserrat",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  SvgPicture.asset(
                    'assets/images/info_data.svg',
                    height: 170,
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: occupation,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Occupation",
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Input your current occupation",
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: interests,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Interest(s)",
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText:
                                  "If more than one, separate with a comma",
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: bio,
                            minLines: 3,
                            maxLines: 10,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Bio",
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Write something about yourself",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: submit,
                    child: Container(
                      height: 50.0,
                      width: 350.0,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Center(
                        child: Text(
                          "CONTINUE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
