import 'package:flutter/material.dart';
import 'package:ybb/widgets/default_appbar.dart';

class IYSMain extends StatefulWidget {
  @override
  _IYSMainState createState() => _IYSMainState();
}

class _IYSMainState extends State<IYSMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Istanbul Youth Summit", removeBackButton: true),
      body: Container(
        child: Text("Hello"),
      ),
    );
  }
}
