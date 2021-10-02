import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ybb/helpers/api/upload_letter.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/dialog.dart';

class UploadAl extends StatefulWidget {
  UploadAl({Key key}) : super(key: key);

  @override
  _UploadAlState createState() => _UploadAlState();
}

class _UploadAlState extends State<UploadAl> {
  File letterFile;
  String fileName;

  final GlobalKey<State> _key = GlobalKey<State>();

  Future getFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile f = result.files.first;

      setState(() {
        letterFile = File(result.files.single.path);
        fileName = f.name;
      });
    } else {
      // User canceled the picker
    }
  }

  buildTextPaymentInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: RichText(
        softWrap: true,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: <TextSpan>[
            TextSpan(
              text: "Note: ",
              style: TextStyle(
                fontFamily: fontName,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text:
                  "You can upload the agreement letter that has been filled out and signed by clicking the button below. The scanned document must be in the PDF format.",
              style: TextStyle(
                fontFamily: fontName,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildUploadButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 30),
          letterFile == null
              ? Container()
              : Center(
                  child: Text(
                    fileName,
                    style: TextStyle(
                      fontFamily: fontName,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              getFile();
            },
            child: Container(
              height: 40.0,
              width: MediaQuery.of(context).size.width * 0.55,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Center(
                child: Text(
                  "Choose File",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  checkForms() {
    if (letterFile == null) {
      Fluttertoast.showToast(
          msg: "Please choose the file first!",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    } else {
      uploadFile();
    }
  }

  uploadFile() async {
    Dialogs.showLoadingDialog(context, _key);
    //Navigator.of(context).pop();

    Map<String, dynamic> data = {
      'id_participant': currentUser.id,
    };

    try {
      await UploadLetter.uploadFile(data, letterFile);

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      Fluttertoast.showToast(
          msg: "Agreement Letter uploaded. Tap again to check.",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1);
    } on Exception catch (e) {
      print(e);
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "An error occured! Please try again later.",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1);
    }
  }

  buildUpload() {
    return ListView(
      children: [
        buildTextPaymentInfo(),
        buildUploadButton(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () {
              checkForms();
            },
            child: Container(
              height: 50.0,
              width: 350.0,
              decoration: BoxDecoration(
                color: letterFile == null ? Colors.grey : Colors.blue,
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Center(
                child: Text(
                  "SUBMIT",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "Upload",
          style: appBarTextStyle,
        ),
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
      ),
      body: buildUpload(),
    );
  }
}
