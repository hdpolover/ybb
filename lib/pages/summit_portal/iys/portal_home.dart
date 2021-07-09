import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ybb/widgets/default_appbar.dart';

class PortalHome extends StatefulWidget {
  @override
  _PortalHomeState createState() => _PortalHomeState();
}

class _PortalHomeState extends State<PortalHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Summit Portal", removeBackButton: true),
      body: ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(20),
        children: [
          SummitInfoTile(
            siFile:
                "https://images.unsplash.com/photo-1597466765990-64ad1c35dafc",
            siDesc:
                "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
            siDate: "2021-10-01",
          ),
          SummitInfoTile(
            siFile:
                "https://images.unsplash.com/photo-1597466765990-64ad1c35dafc",
            siDesc:
                "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
            siDate: "2021-10-01",
          ),
          SummitInfoTile(
            siFile:
                "https://images.unsplash.com/photo-1597466765990-64ad1c35dafc",
            siDesc:
                "Youth Break the Boundaries (YBB) Foundation organizes several youth summits annually. We aim to sharpen up the spirit of talented youth leaders in various areas, build a character of youth leadership, and the existence of the youth in international scenes.",
            siDate: "2021-10-01",
          ),
        ],
      ),
    );
  }
}

class SummitInfoTile extends StatelessWidget {
  final String siFile, siDesc, siDate;

  SummitInfoTile({
    @required this.siFile,
    @required this.siDesc,
    @required this.siDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: siFile,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                siDesc,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Posted on",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "OpenSans",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    siDate,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "OpenSans",
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
