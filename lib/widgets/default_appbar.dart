import 'package:flutter/material.dart';

AppBar defaultAppBar(context,
    {@required String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: "Montserrat",
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.blue,
  );
}
