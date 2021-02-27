import 'package:flutter/material.dart';

AppBar defaultAppBar(context,
    {@required String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    leading: removeBackButton
        ? Text('')
        : IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
    backgroundColor: Theme.of(context).primaryColor,
  );
}
