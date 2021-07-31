import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/api/summit_content.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/full_pdf.dart';
import 'package:ybb/widgets/full_photo.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ybb/widgets/shimmers/summit_item_shimmer_layout.dart';

class PortalHome extends StatefulWidget {
  @override
  _PortalHomeState createState() => _PortalHomeState();
}

class _PortalHomeState extends State<PortalHome>
    with AutomaticKeepAliveClientMixin<PortalHome> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  List<SummitContent> sc = [];

  getSummitContents() {
    return FutureBuilder(
      future: SummitContent.getSummitContents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SummitItemShimmer();
        }

        List<SummitContent> rawSc = snapshot.data;

        sc = rawSc
            .where((element) => element.status == "1")
            .toList()
            .reversed
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 0),
          //controller: _scrollController,
          itemCount: sc.length,
          itemBuilder: (context, index) {
            return SummitInfoTile(
              content: sc[index],
              context: context,
            );
          },
        );
      },
    );
  }

  Future<Null> refreshSummitHome() async {
    refreshkey.currentState?.show(atTop: true);

    setState(() {
      sc = [];
    });

    await getSummitContents();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Summit Portal", removeBackButton: true),
      body: LiquidPullToRefresh(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.blue,
        animSpeedFactor: 2.5,
        backgroundColor: Colors.white,
        showChildOpacityTransition: false,
        key: refreshkey,
        onRefresh: refreshSummitHome,
        child: getSummitContents(),
      ),
    );
  }

  bool get wantKeepAlive => true;
}

class SummitInfoTile extends StatelessWidget {
  final BuildContext context;
  final SummitContent content;

  SummitInfoTile({
    @required this.content,
    @required this.context,
  });

  checkFileContent() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    String url = baseUrl +
        "/assets/img/summit_contents/" +
        content.idSummit.toString() +
        "/" +
        content.filePath;

    if (content.fileType == "pdf") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullPdf(url: url),
            ),
          );
        },
        child: Container(
          width: width,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              border: Border.all(
                style: BorderStyle.solid,
                color: Colors.blue,
              )),
          child: Text(
            content.filePath,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (content.fileType == "no type") {
      return Container();
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullPhoto(url: url),
            ),
          );
        },
        child: Container(
          height: height * 0.3,
          width: width,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                content.title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: fontName,
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                content.description,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 10),
            checkFileContent(),
            SizedBox(height: 10),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Posted",
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: "OpenSans",
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    timeago.format(content.createdDate),
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: "OpenSans",
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
