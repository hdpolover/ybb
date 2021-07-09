import 'package:flutter/material.dart';
import 'package:ybb/widgets/default_appbar.dart';

class PortalProfile extends StatefulWidget {
  @override
  _PortalProfileState createState() => _PortalProfileState();
}

class _PortalProfileState extends State<PortalProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          defaultAppBar(context, titleText: "Profile", removeBackButton: true),
      body: ListView(
        padding: EdgeInsets.all(20),
        scrollDirection: Axis.vertical,
        children: [
          CircleAvatar(
            radius: 90.0,
            backgroundImage: NetworkImage(
                "https://images.unsplash.com/photo-1597466765990-64ad1c35dafc"),
          ),
          SizedBox(height: 30),
          FlatButton(
            color: Colors.blue,
            onPressed: () {},
            child: Text(
              "Show QR Code",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 30),
          Text(
            "Hendra",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
