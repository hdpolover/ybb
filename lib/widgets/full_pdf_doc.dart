import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

var dio = Dio();

class FullPdfDoc extends StatefulWidget {
  final String url;

  FullPdfDoc({Key key, @required this.url}) : super(key: key);

  @override
  _FullPdfDocState createState() => _FullPdfDocState();
}

class _FullPdfDocState extends State<FullPdfDoc> {
  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }),
      );
      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      print("done");
      await raf.close();

      // Fluttertoast.showToast(
      //     msg: "Document downloaded!",
      //     toastLength: Toast.LENGTH_SHORT,
      //     timeInSecForIosWeb: 1);
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.download),
            onPressed: () async {
              if (await Permission.storage.request().isGranted) {
                print("granted");

                String path;
                if (Platform.isAndroid) {
                  //path = (await getExternalStorageDirectory()).path;
                  path = (await getApplicationDocumentsDirectory()).path;
                } else {
                  path = (await getApplicationDocumentsDirectory()).path;
                }

                String fullPath = "$path/test.pdf";
                print('full path $fullPath');

                String url =
                    "http://192.168.1.11/web_ybb/assets/img/docs/AGREEMENT_LETTER.pdf";
                download2(dio, url, fullPath);
              } else if (await Permission.storage.isPermanentlyDenied) {
                openAppSettings();
              }
            },
          ),
        ],
      ),
      body: FullPhotoScreen(url: widget.url),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  FullPhotoScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(url);
    return SfPdfViewer.network(url);
  }
}
