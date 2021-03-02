import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/webview_shimmer_layout.dart';

class TermsConditionsView extends StatefulWidget {
  @override
  _TermsConditionsView createState() => _TermsConditionsView();
}

class _TermsConditionsView extends State<TermsConditionsView> {
  String url = "https://youthbreaktheboundaries.com/terms-and-conditions/";

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
      appBar: defaultAppBar(context, titleText: "Terms and Conditions"),
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
          WebviewShimmer(),
        ],
      ),
    );
  }
}
