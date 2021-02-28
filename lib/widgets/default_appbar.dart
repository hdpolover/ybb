import 'package:flutter/material.dart';
import 'package:ybb/helpers/constants.dart';

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
      style: appBarTextStyle,
    ),
    elevation: 0,
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}
