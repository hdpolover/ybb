import 'package:flutter/material.dart';

const backgroundColor = Colors.blueGrey;

final fontName = "OpenSans";

final hintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final commonTextStyle = TextStyle(
  color: Colors.black,
  fontFamily: 'OpenSans',
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
