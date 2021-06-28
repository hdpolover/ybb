import 'package:flutter/material.dart';
import 'package:ybb/widgets/default_appbar.dart';

class SummitRegister extends StatefulWidget {
  @override
  _SummitRegisterState createState() => _SummitRegisterState();
}

class _SummitRegisterState extends State<SummitRegister> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Summit Registration", removeBackButton: true),
      body: Container(
        child: Text("Hello"),
      ),
    );
  }
}
