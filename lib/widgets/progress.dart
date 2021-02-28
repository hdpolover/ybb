import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.blue),
        ),
      ));
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blue),
    ),
  );
}
