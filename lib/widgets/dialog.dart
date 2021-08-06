import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ybb/helpers/api/summit_participant.dart';
import 'package:ybb/helpers/constants.dart';

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

  static Future<void> showParticipantQrCode(
      BuildContext context, GlobalKey key, String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: SummitParticipant.getParticipant(id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            SummitParticipant s = snapshot.data;
            String url = baseUrl + "/assets/img/qr_codes/" + s.qrCode;
            return SimpleDialog(
              key: key,
              elevation: 0,
              contentPadding: EdgeInsets.all(8),
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: NetworkImage(url),
                      //image: AssetImage('assets/images/default_photo.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
