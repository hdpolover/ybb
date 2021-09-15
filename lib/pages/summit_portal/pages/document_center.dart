import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/home.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(int progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  Future<ShouldOverrideUrlLoadingAction> shouldOverrideUrlLoading(
      ShouldOverrideUrlLoadingRequest shouldOverrideUrlLoadingRequest) async {
    print("\n\n override ${shouldOverrideUrlLoadingRequest.url}\n\n");
    return ShouldOverrideUrlLoadingAction.ALLOW;
  }

  @override
  void onLoadResource(LoadedResource response) {
    print("Started at: " +
        response.startTime.toString() +
        "ms ---> duration: " +
        response.duration.toString() +
        "ms " +
        response.url);
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
    print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
  }
}

class DocumentCenter extends StatefulWidget {
  final MyInAppBrowser browser = new MyInAppBrowser();

  @override
  _DocumentCenterState createState() => _DocumentCenterState();
}

class _DocumentCenterState extends State<DocumentCenter> {
  var options = InAppBrowserClassOptions(
      crossPlatform: InAppBrowserOptions(hideUrlBar: false),
      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));

  TextStyle titleStyle = new TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  TextStyle contentStyle = new TextStyle(
    fontFamily: fontName,
    letterSpacing: 0.7,
  );

  InAppWebViewController webView;
  String url = "";
  double progress = 0;

  // final _key = UniqueKey();
  // num _stackToView = 1;

  // void _handleLoad(String value) {
  //   setState(() {
  //     _stackToView = 0;
  //   });
  // }

  @override
  void initState() {
    super.initState();
  }

  buildWebView() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrl: baseUrl + "/summit_docs/result/" + currentUser.id,
                  initialHeaders: {},
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                    debuggingEnabled: true,
                  )),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    setState(() {
                      this.url = url;
                    });
                  },
                  onLoadStop:
                      (InAppWebViewController controller, String url) async {
                    setState(() {
                      this.url = url;
                    });
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: RichText(
              softWrap: true,
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: fontName,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text:
                        "If the download buttons don't work, tap the 3 dots on the top to open your browser.",
                    style: TextStyle(
                      fontFamily: fontName,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  openBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: "Cannot launch browser!",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  // buildNoDocument() {
  //   return Center(
  //     child: Container(
  //       alignment: Alignment.center,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           //buildDocTile(),
  //           buildWebView(),
  //           // SvgPicture.asset(
  //           //   'assets/images/no_doc.svg',
  //           //   height: MediaQuery.of(context).size.width * 0.4,
  //           // ),
  //           // SizedBox(height: MediaQuery.of(context).size.height * 0.05),
  //           // Text(
  //           //   "There are no documents yet. Come back next time.",
  //           //   textAlign: TextAlign.center,
  //           //   style: TextStyle(
  //           //     fontFamily: fontName,
  //           //   ),
  //           // ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // buildWebView() {
  //   return IndexedStack(
  //     index: _stackToView,
  //     children: [
  //       Column(
  //         children: <Widget>[
  //           Expanded(
  //             child: WebView(
  //               key: _key,
  //               initialUrl: "http://192.168.1.11/web_ybb/summit_docs/result/" +
  //                   currentUser.id,
  //               onPageFinished: _handleLoad,
  //               onWebResourceError: (error) => showDialog<void>(
  //                 context: context,
  //                 barrierDismissible: false,
  //                 barrierColor: Colors.black38,
  //                 builder: (BuildContext context) {
  //                   return SimpleDialog(
  //                     elevation: 0,
  //                     children: <Widget>[
  //                       Center(
  //                         child: Column(
  //                           children: [
  //                             SizedBox(
  //                               height: 20,
  //                             ),
  //                             SpinKitThreeBounce(
  //                               size: 35,
  //                               itemBuilder: (BuildContext context, int index) {
  //                                 return DecoratedBox(
  //                                   decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(50),
  //                                       color: Theme.of(context).primaryColor),
  //                                 );
  //                               },
  //                             ),
  //                             SizedBox(
  //                               height: 10,
  //                             ),
  //                             Text(
  //                               "Please wait...",
  //                               style: TextStyle(color: Colors.blueAccent),
  //                             ),
  //                             SizedBox(
  //                               height: 20,
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       //WebviewShimmer()
  //       Container(),
  //     ],
  //   );
  // }

  // buildDocTile() {
  //   return Padding(
  //     padding: const EdgeInsets.all(10.0),
  //     child: Container(
  //       margin: EdgeInsets.only(bottom: 10),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           Container(
  //             child: Text(
  //               "Letter of Accentance",
  //               textAlign: TextAlign.start,
  //               style: TextStyle(
  //                 fontFamily: fontName,
  //                 color: Colors.black,
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //           SizedBox(height: 10),
  //           GestureDetector(
  //             onTap: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => FullPdfDoc(
  //                       url:
  //                           "http://192.168.1.11/web_ybb/assets/img/docs/AGREEMENT_LETTER.pdf"),
  //                 ),
  //               );
  //             },
  //             child: Container(
  //               width: double.infinity,
  //               padding: EdgeInsets.all(10),
  //               decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.all(Radius.circular(6)),
  //                   border: Border.all(
  //                     style: BorderStyle.solid,
  //                     color: Colors.blue,
  //                   )),
  //               child: Text(
  //                 "content.filePath",
  //                 textAlign: TextAlign.justify,
  //                 style: TextStyle(
  //                   fontFamily: 'OpenSans',
  //                   color: Colors.blue,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Document Center",
          style: appBarTextStyle,
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              //const PopupMenuItem(child: Text('Tampilkan dengan WebView')),
              const PopupMenuItem(
                child: Text('Open in browser'),
                value: 0,
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 0:
                  openBrowser(
                      baseUrl + "/summit_docs/result/" + currentUser.id);
                  break;
                default:
                  break;
              }
            },
          ),
        ],
      ),
      body: buildWebView(),
    );
  }
}
