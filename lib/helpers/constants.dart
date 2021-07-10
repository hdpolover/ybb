import 'package:flutter/material.dart';

const backgroundColor = Colors.blueGrey;
const primaryColor = Colors.blue;
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);

final fontName = "OpenSans";

final int postTimelineLimit = 5;

final kTitleStyle = TextStyle(
  fontWeight: FontWeight.bold,
  letterSpacing: 1,
  color: Colors.blue,
  fontFamily: fontName,
  fontSize: 26.0,
  height: 1.5,
);

final kSubtitleStyle = TextStyle(
  fontFamily: fontName,
  color: Colors.black,
  fontSize: 18.0,
  height: 1.2,
  letterSpacing: .7,
);

final hintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: fontName,
);

final commonTextStyle = TextStyle(
  color: Colors.black,
  fontFamily: fontName,
  letterSpacing: .7,
);

final boxDecorationStyle = BoxDecoration(
  color: Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

final appBarTextStyle = TextStyle(
  color: Colors.white,
  fontFamily: "SFProText",
  fontSize: 20.0,
  letterSpacing: 1,
);
