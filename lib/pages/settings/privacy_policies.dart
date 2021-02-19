import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/progress.dart';

class PrivacyPoliciesView extends StatefulWidget {
  @override
  _PrivacyPoliciesView createState() => _PrivacyPoliciesView();
}

class _PrivacyPoliciesView extends State<PrivacyPoliciesView> {
  String url = "https://youthbreaktheboundaries.com/privacy-policies/";

  final _key = UniqueKey();
  num _stackToView = 1;

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, titleText: "Privacy Policies"),
      body: IndexedStack(
        index: _stackToView,
        children: [
          Column(
            children: <Widget>[
              Expanded(
                  child: WebView(
                key: _key,
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: url,
                onPageFinished: _handleLoad,
              )),
            ],
          ),
          Container(
            color: Colors.white,
            child: Center(
              child: circularProgress(),
            ),
          ),
        ],
      ),
    );
  }
}
