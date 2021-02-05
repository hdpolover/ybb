import 'package:flutter/material.dart';

Column circularProgress() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 10.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.blue),
          )),
    ],
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blue),
    ),
  );
}
