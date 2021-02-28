import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/progress.dart';
import 'package:image/image.dart' as Im;

import 'home.dart';

class UploadPost extends StatefulWidget {
  final User currentUser;

  UploadPost({this.currentUser});

  @override
  _UploadPostState createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost>
    with AutomaticKeepAliveClientMixin<UploadPost> {
  TextEditingController descController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String downloadUrl;

  String text;
  File _image;
  final picker = ImagePicker();

  bool isUploading = false;
  String postId = Uuid().v4();

  Future handleCamera() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future handleGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Choose an image..."),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Camera"),
                onPressed: handleCamera,
              ),
              SimpleDialogOption(
                child: Text("Gallery"),
                onPressed: handleGallery,
              ),
            ],
          );
        });
  }

  clearImageAndBack() {
    setState(() {
      _image = null;
    });

    Navigator.pop(context);
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image imageFile = Im.decodeImage(_image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 70));

    setState(() {
      _image = compressedImageFile;
    });
  }

  uploadImageFile(imageFile) async {
    Reference ref = storageRef.child("Posts").child("post_$postId.jpg");

    await ref.putFile(imageFile).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        downloadUrl = value;
      });
    });
  }

  createPostInFirestore({String desc, String mediaUrl}) {
    postsRef.doc(widget.currentUser.id).collection("userPosts").doc(postId).set(
      {
        "postId": postId,
        "ownerId": widget.currentUser.id,
        "displayName": widget.currentUser.displayName,
        "mediaUrl": mediaUrl,
        "description": desc,
        "timestamp": timestamp,
        "likes": {}
      },
    );
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    String mediaUrl = "";

    try {
      await compressImage();
      await uploadImageFile(_image);

      mediaUrl = downloadUrl;
    } catch (e) {
      mediaUrl = "";
    }

    createPostInFirestore(
      desc: descController.text,
      mediaUrl: mediaUrl,
    );

    descController.clear();
    setState(() {
      _image = null;
      isUploading = false;
      postId = Uuid().v4();
    });

    SnackBar snackBar = SnackBar(content: Text("Posted successfully!"));
    _scaffoldKey.currentState.showSnackBar(snackBar);

    Timer(
      Duration(seconds: 2),
      () {
        Navigator.pop(context);
      },
    );
  }

  bool isNotFilled() {
    return _image == null && text == null;
  }

  showError() {
    SnackBar snackBar =
        SnackBar(content: Text("Please fill out the fields first!"));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: clearImageAndBack,
        ),
        title: Text(
          "Create New Post",
          style: appBarTextStyle,
        ),
        actions: [
          FlatButton(
            onPressed: isNotFilled()
                ? showError
                : isUploading
                    ? null
                    : () => handleSubmit(),
            child: Text(
              'POST',
              style: TextStyle(
                color: Colors.white,
                fontFamily: "OpenSans",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(''),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            child: Container(
              child: TextField(
                controller: descController,
                onChanged: (value) {
                  setState(() {
                    text = descController.text;
                  });
                },
                minLines: 1,
                maxLines: 20,
                decoration: InputDecoration(
                  hintText: "Write something here...",
                  hintStyle: commonTextStyle,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onTap: () {
                    selectImage(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _image == null
                            ? AssetImage(
                                'assets/images/placeholder_ybb_news.jpg')
                            : FileImage(_image),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Text(
                "*Click above image to add/change with another",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontFamily: "OpenSans",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;
}
