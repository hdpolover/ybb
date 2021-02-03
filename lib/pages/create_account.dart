import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ybb/widgets/default_appbar.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

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
        appBar: defaultAppBar(context,
            titleText: "User Details", removeBackButton: true),
        body: ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Center(
                      child: Text(
                        "Let others know you by providing your personal information",
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          validator: (val) {
                            if (val.trim().length < 3 || val.isEmpty) {
                              return "Username too short";
                            } else if (val.trim().length > 12) {
                              return "Username too long";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => username = val,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Username",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Must be at least 3 characters",
                          ),
                        ),
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
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: submit,
                    child: Container(
                      height: 50.0,
                      width: 350.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7.0),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          "SKIP FOR NOW",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
