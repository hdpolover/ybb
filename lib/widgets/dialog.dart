import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (BuildContext context) {
        return SimpleDialog(
          key: key,
          elevation: 0,
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  SpinKitThreeBounce(
                    size: 35,
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Theme.of(context).primaryColor),
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Please wait...",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showRegisterDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (BuildContext context) {
        return SimpleDialog(
          key: key,
          elevation: 0,
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  SpinKitThreeBounce(
                    size: 35,
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Theme.of(context).primaryColor),
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Registering account...",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
