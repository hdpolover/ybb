import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:image/image.dart' as Im;
import 'package:ybb/widgets/shimmers/profile_dashboard_shimmer_layout.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController interestController = TextEditingController();

  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _usernameValid = true;
  bool _bioValid = true;
  bool _occupationValid = true;

  FocusNode focusNode;
  FocusNode focusNode1;
  //FocusNode focusNode2;

  String downloadUrl;

  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getUser();

    focusNode = FocusNode();
    focusNode1 = FocusNode();
    //focusNode2 = FocusNode();
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
      },
    );
  }

  clearImageAndBack() {
    setState(() {
      _image = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    String id = widget.currentUserId;
    Im.Image imageFile = Im.decodeImage(_image.readAsBytesSync());
    final compressedImageFile = File('$path/profile_pic_$id.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 70));

    setState(() {
      _image = compressedImageFile;
    });
  }

  uploadImageFile(imageFile) async {
    String id = widget.currentUserId;

    Reference ref = storageRef
        .child("Users")
        .child(widget.currentUserId)
        .child("profile_pic_$id.jpg");

    await ref.putFile(imageFile).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        downloadUrl = value;
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    focusNode1.dispose();
    //focusNode2.dispose();

    super.dispose();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);

    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    usernameController.text = user.username;
    occupationController.text = user.occupation;
    interestController.text = user.interests;

    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          focusNode: focusNode,
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update display name",
            errorText: _displayNameValid ? null : "Display name is too short",
          ),
        ),
      ],
    );
  }

  Column buildOccupationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "Occupation",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: occupationController,
          decoration: InputDecoration(
            hintText: "Update current occupation",
            errorText: _occupationValid ? null : "Occupation is not valid",
          ),
        ),
      ],
    );
  }

  Column buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "Username",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          //focusNode: focusNode2,
          controller: usernameController,
          decoration: InputDecoration(
            hintText: user.username,
            errorText: _usernameValid ? null : "Username is too short",
          ),
        ),
      ],
    );
  }

  Column buildInterestField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "Interests",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          //focusNode: focusNode2,
          controller: interestController,
          decoration: InputDecoration(
            hintText: user.interests,
          ),
        ),
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          maxLines: 10,
          minLines: 1,
          focusNode: focusNode1,
          controller: bioController,
          decoration: InputDecoration(
            hintText: user.bio.length == 0 ? "Update bio" : user.bio,
            errorText: _bioValid ? null : "Bio is too long",
          ),
        ),
      ],
    );
  }

  updateProfileData() async {
    focusNode.unfocus();
    focusNode1.unfocus();
    //focusNode2.unfocus();

    String mediaUrl = "";

    try {
      await compressImage();
      await uploadImageFile(_image);

      mediaUrl = downloadUrl;
    } catch (e) {
      mediaUrl = user.photoUrl;
    }

    setState(() {
      displayNameController.text.trim().length < 5 ||
              displayNameController.text.trim().isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;

      usernameController.text.trim().length < 5 ||
              usernameController.text.trim().isEmpty
          ? _usernameValid = false
          : _usernameValid = true;

      bioController.text.trim().length > 200
          ? _bioValid = false
          : _bioValid = true;

      occupationController.text.trim().length < 3
          ? _occupationValid = false
          : _occupationValid = true;
    });

    if (_displayNameValid && _bioValid && _usernameValid && _occupationValid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
        "username": usernameController.text,
        "occupation": occupationController.text,
        "interests": interestController.text,
        "photoUrl": mediaUrl,
        "dnSearchKey": displayNameController.text.substring(0, 1).toUpperCase(),
      });

      clearImageAndBack();

      SnackBar snackBar =
          SnackBar(content: Text("Profile successfully updated!"));
      _scaffoldKey.currentState.showSnackBar(snackBar);

      //Navigator.pop(context);
      Timer(
        Duration(seconds: 2),
        () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text("Edit Profile", style: appBarTextStyle),
        actions: <Widget>[
          ConnectivityWidgetWrapper(
            stacked: false,
            offlineWidget: IconButton(
              icon: Icon(
                Icons.save,
                color: Colors.white38,
              ),
              onPressed: null,
            ),
            child: IconButton(
              icon: Icon(Icons.save),
              onPressed: updateProfileData,
            ),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ConnectivityScreenWrapper(
        child: isLoading
            ? ProfileDashboardShimmer()
            : ListView(
                children: [
                  Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            selectImage(context);
                          },
                          child: Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 16.9),
                                child: CircleAvatar(
                                  radius: 50.0,
                                  backgroundImage: _image == null
                                      ? CachedNetworkImageProvider(
                                          user.photoUrl)
                                      : FileImage(_image),
                                ),
                              ),
                              Icon(
                                Icons.photo_camera,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              buildUsernameField(),
                              buildDisplayNameField(),
                              buildOccupationField(),
                              buildInterestField(),
                              buildBioField(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
