import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/profile_dashboard_shimmer_layout.dart';

class SPHome extends StatefulWidget {
  SPHome({Key key}) : super(key: key);

  @override
  _SPHomeState createState() => _SPHomeState();
}

class _SPHomeState extends State<SPHome> {
  buildSummitTile(String summitName, String imgUrl, Widget pageTo) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => pageTo,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.15,
                  fit: BoxFit.cover,
                  imageUrl: imgUrl),
            ),
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: Colors.black12,
              ),
              child: Text(
                summitName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "OpenSans",
                  letterSpacing: 1,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, titleText: "Summit Portal"),
      body: Center(
        child: Column(
          children: [
            buildSummitTile(
              "Istanbul Youth Summit",
              "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
              SPHome(),
            ),
            buildSummitTile(
              "Asia Youth Summit",
              "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
              SPHome(),
            ),
            buildSummitTile(
              "Digital Youth Summit",
              "https://images.unsplash.com/photo-1589463779377-26cb6db03a35?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=889&q=80",
              SPHome(),
            ),
          ],
        ),
      ),
    );
  }
}
