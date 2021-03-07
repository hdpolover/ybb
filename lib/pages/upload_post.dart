import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/dialog.dart';
import 'package:image/image.dart' as Im;

import 'home.dart';

class UploadPost extends StatefulWidget {
  final AppUser currentUser;

  UploadPost({this.currentUser});

  @override
  _UploadPostState createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost>
    with AutomaticKeepAliveClientMixin<UploadPost> {
  TextEditingController descController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String downloadUrl;

  FocusNode focusNode;

  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  String text;
  File _image;
  final picker = ImagePicker();

  bool isUploading = false;
  String postId = Uuid().v4();
  List<String> followers = [];
  bool _uploadValid = true;

  @override
  void initState() {
    super.initState();

    getFollowers();

    focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    focusNode.dispose();
  }

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
    String id = timePosted.millisecondsSinceEpoch.toString();

    Reference ref = storageRef.child("Posts").child("pimage_$id.jpg");

    await ref.putFile(imageFile).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        downloadUrl = value;
      });
    });
  }

  Future<void> getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.currentUser.id)
        .collection('userFollowers')
        .get();

    setState(() {
      followers = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  var timePosted = DateTime.now();

  createPostInFirestore({String desc, String mediaUrl}) async {
    String id = timePosted.millisecondsSinceEpoch.toString();

    await postsRef
        .doc(widget.currentUser.id)
        .collection("userPosts")
        .doc(id)
        .set(
      {
        "postId": id,
        "ownerId": widget.currentUser.id,
        "mediaUrl": mediaUrl,
        "description": desc,
        "timestamp": timePosted,
        "likes": {}
      },
    );
  }

  handleSubmit() async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    focusNode.unfocus();

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

    if (descController.text.toString().trim().isEmpty) {
      setState(() {
        _uploadValid = false;
      });
    } else {
      setState(() {
        _uploadValid = true;
      });
    }

    await createPostInFirestore(
      desc: descController.text,
      mediaUrl: mediaUrl,
    );

    descController.clear();
    setState(() {
      _image = null;
      isUploading = false;
      postId = Uuid().v4();
    });

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pop(context);

    // SnackBar snackBar = SnackBar(
    //     backgroundColor: Colors.blue, content: Text("Posted successfully!"));
    // _scaffoldKey.currentState.showSnackBar(snackBar);

    // Timer(
    //   Duration(seconds: 2),
    //   () {
    //     Navigator.pop(context);
    //   },
    // );
  }

  bool isNotFilled() {
    return _image == null && descController.text.isEmpty ? true : false;
  }

  showError() {
    setState(() {
      _uploadValid = false;
    });

    SnackBar snackBar = SnackBar(
        backgroundColor: Colors.blue,
        content: Text("Please fill out at least one of the fields first!"));
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
          ConnectivityWidgetWrapper(
            stacked: false,
            offlineWidget: FlatButton(
              onPressed: null,
              child: Text(
                'POST',
                style: TextStyle(
                  color: Colors.white30,
                  fontFamily: fontName,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child: FlatButton(
              onPressed: isNotFilled()
                  ? null
                  : isUploading
                      ? null
                      : () => handleSubmit(),
              child: Text(
                'POST',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: fontName,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ConnectivityScreenWrapper(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.005,
                ),
                ListTile(
                  title: TextFormField(
                    focusNode: focusNode,
                    controller: descController,
                    onChanged: (value) {
                      setState(() {
                        _uploadValid = true;
                      });
                    },
                    minLines: 3,
                    maxLines: 30,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "What do you have in mind?",
                      errorText: _uploadValid
                          ? null
                          : "Please write something here...",
                      hintStyle: TextStyle(
                        fontFamily: fontName,
                      ),
                    ),
                  ),
                  leading: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.07,
                      backgroundImage:
                          CachedNetworkImageProvider(currentUser.photoUrl)),
                ),
                // Row(
                //   children: [
                //     CircleAvatar(
                //       radius: 40.0,
                //       backgroundColor: Colors.grey,
                //       backgroundImage:
                //           CachedNetworkImageProvider(currentUser.photoUrl),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                //       child: Container(
                //         child: TextFormField(
                //           focusNode: focusNode,
                //           controller: descController,
                //           onChanged: (value) {
                //             setState(() {
                //               text = descController.text;
                //             });
                //           },
                //           minLines: 1,
                //           maxLines: 30,
                //           decoration: InputDecoration(
                //             hintText: "Write something here...",
                //             hintStyle: commonTextStyle,
                //             border: InputBorder.none,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                //isUploading ? linearProgress() : Text(''),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  decoration: _uploadValid
                      ? null
                      : BoxDecoration(
                          border: Border.all(color: Colors.red),
                        ),
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.9,
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
                      "*Click the image above to add/change an image",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontFamily: fontName,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}
