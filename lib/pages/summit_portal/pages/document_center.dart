import 'package:flutter/material.dart';
import 'package:ybb/helpers/api/summit_participant_details.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:flutter_svg/svg.dart';

class DocumentCenter extends StatefulWidget {
  final SummitParticipantDetails data;

  DocumentCenter({@required this.data});

  @override
  _DocumentCenterState createState() => _DocumentCenterState();
}

class _DocumentCenterState extends State<DocumentCenter> {
  SummitParticipantDetails spd;
  String participantName = "";
  String participantId = "";

  TextStyle titleStyle = new TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  TextStyle contentStyle = new TextStyle(
    fontFamily: fontName,
    letterSpacing: 0.7,
  );

  @override
  void initState() {
    super.initState();
    spd = widget.data;
    participantName = spd.fullName;
    participantId = spd.participantId;
  }

  buildNoDocument() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/no_doc.svg',
              height: MediaQuery.of(context).size.width * 0.4,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text(
              "There are no documents yet. Come back next time.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: fontName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(
        context,
        titleText: "Document Center",
        removeBackButton: false,
      ),
      body: buildNoDocument(),
    );
  }
}
