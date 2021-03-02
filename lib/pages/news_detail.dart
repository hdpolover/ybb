import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/widgets/shimmers/webview_shimmer_layout.dart';

class NewsDetail extends StatefulWidget {
  final String url, title, imageUrl, date, category, content;

  NewsDetail(
      {this.url,
      this.title,
      this.imageUrl,
      this.date,
      this.category,
      this.content});

  @override
  _NewsDetailState createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  //final Completer<WebViewController> _completer = Completer<WebViewController>();
  bool webViewSelected = true;

  final _key = UniqueKey();
  num _stackToView = 1;

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  String convertDateTime(DateTime postedDate) {
    return DateFormat.yMMMd().format(postedDate);
  }

  buildNewsView() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: Text(
                widget.title.trim(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(width: 5),
                      Text(
                        convertDateTime(DateTime.parse(widget.date)).toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "OpenSans",
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.folder_open_outlined,
                        color: Colors.black,
                        size: 22,
                      ),
                      SizedBox(width: 5),
                      Text(
                        widget.category,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "OpenSans",
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                widget.content,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildNewsWebView() {
    return IndexedStack(
      index: _stackToView,
      children: [
        Column(
          children: <Widget>[
            Expanded(
                child: WebView(
              key: _key,
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: widget.url,
              onPageFinished: _handleLoad,
            )),
          ],
        ),
        WebviewShimmer()
      ],
    );
  }

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
          "News Detail",
          style: appBarTextStyle,
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        // actions: [
        //   PopupMenuButton(
        //     icon: Icon(Icons.more_vert),
        //     itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        //       const PopupMenuItem(child: Text('Tampilkan dengan WebView')),
        //       const PopupMenuItem(child: Text('Buka di browser')),
        //     ],
        //   ),
        // ],
      ),
      body: webViewSelected ? buildNewsWebView() : buildNewsView(),
    );
  }
}
