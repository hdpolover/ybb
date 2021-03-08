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

  TextEditingController emailController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  bool showContacts = false;
  bool finalShowContacts = false;

  bool isLoading = false;
  AppUser user;
  bool _displayNameValid = true;
  bool _usernameValid = true;
  bool _bioValid = true;
  bool _occupationValid = true;
  bool _isUsernameAvailable = true;

  FocusNode focusNode;
  FocusNode focusNode1;
  FocusNode focusNode2;

  List<String> allUsernames = [];
  String currentUsername = "";
  String downloadUrl;

  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    getUser();
    getAllUsernames();

    focusNode = FocusNode();
    focusNode1 = FocusNode();
    focusNode2 = FocusNode();
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
    focusNode2.dispose();

    super.dispose();
  }

  getAllUsernames() async {
    QuerySnapshot snapshot = await usersRef.get();

    snapshot.docs.forEach((element) {
      allUsernames.add(element['username']);
    });

    print(allUsernames.length);
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = AppUser.fromDocument(doc);

    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    usernameController.text = user.username;
    occupationController.text = user.occupation;
    interestController.text = user.interests;
    emailController.text = user.email;

    showContacts = user.showContacts;
    instagramController.text = user.instagram;
    facebookController.text = user.facebook;
    websiteController.text = user.website;
    phoneNumberController.text = user.phoneNumber;

    setState(() {
      isLoading = false;
      currentUsername = user.username;
    });
  }

  Padding buildDisplayNameField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        focusNode: focusNode,
        style: TextStyle(fontFamily: fontName),
        controller: displayNameController,
        minLines: 1,
        maxLines: 4,
        maxLength: 35,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Display name",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: user.displayName,
          errorText: _displayNameValid ? null : "Display name is too short",
        ),
      ),
    );
  }

  Padding buildOccupationField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: occupationController,
        minLines: 1,
        maxLines: 3,
        maxLength: 50,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Occupation",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input your current occupation",
          errorText: _occupationValid ? null : "Occupation is not valid",
        ),
      ),
    );
  }

  Padding buildUsernameField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        focusNode: focusNode1,
        style: TextStyle(fontFamily: fontName),
        controller: usernameController,
        minLines: 1,
        maxLines: 3,
        maxLength: 20,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Username",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: user.username,
          errorText: _usernameValid
              ? _isUsernameAvailable
                  ? null
                  : "Username is unavailable"
              : "Username is too short",
        ),
      ),
    );
  }

  Padding buildInterestField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        focusNode: focusNode2,
        style: TextStyle(fontFamily: fontName),
        controller: interestController,
        minLines: 1,
        maxLines: 10,
        maxLength: 100,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Interests",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input your interests",
        ),
      ),
    );
  }

  Padding buildBioField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: bioController,
        minLines: 1,
        maxLines: 30,
        maxLength: 500,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontFamily: fontName,
            fontWeight: FontWeight.bold,
          ),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Bio",
          labelStyle: TextStyle(fontFamily: fontName),
          errorText: _bioValid ? null : "Bio is too long",
        ),
      ),
    );
  }

  updateProfileData() async {
    focusNode.unfocus();
    focusNode1.unfocus();
    focusNode2.unfocus();

    String mediaUrl = "";

    try {
      await compressImage();
      await uploadImageFile(_image);

      mediaUrl = downloadUrl;
    } catch (e) {
      mediaUrl = user.photoUrl;
    }

    if (usernameController.text.toString().trim() == currentUsername) {
      setState(() {
        _isUsernameAvailable = true;
      });
    } else {
      for (int i = 0; i < allUsernames.length; i++) {
        if (usernameController.text.toString().trim() == allUsernames[i]) {
          setState(() {
            _isUsernameAvailable = false;
          });
          return;
        } else {
          setState(() {
            _isUsernameAvailable = true;
          });
        }
      }
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

      bioController.text.trim().length > 300
          ? _bioValid = false
          : _bioValid = true;

      occupationController.text.trim().length < 3
          ? _occupationValid = false
          : _occupationValid = true;
    });

    if (_displayNameValid &&
        _bioValid &&
        _usernameValid &&
        _occupationValid &&
        _isUsernameAvailable) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text.trim(),
        "bio": bioController.text.trim(),
        "username": usernameController.text.trim(),
        "occupation": occupationController.text.trim(),
        "interests": interestController.text.trim(),
        "photoUrl": mediaUrl,
        "dnSearchKey": displayNameController.text.substring(0, 1).toUpperCase(),
        "instagram": instagramController.text.trim(),
        "phoneNumber": phoneNumberController.text.trim(),
        "facebook": facebookController.text.trim(),
        "website": websiteController.text.trim(),
        "showContacts": showContacts,
      });

      clearImageAndBack();

      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.blue,
        content: Text("Profile successfully updated!"),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);

      //Navigator.pop(context);
      Timer(
        Duration(seconds: 2),
        () {
          Navigator.of(context).pop();
        },
      );
    } else {
      return;
    }
  }

  bool checkFields() {
    try {
      return user.bio == bioController.text.trim() &&
          user.username == usernameController.text.trim() &&
          user.displayName == displayNameController.text.trim() &&
          user.occupation == occupationController.text.trim() &&
          user.interests == interestController.text.trim() &&
          user.showContacts == showContacts &&
          user.phoneNumber == phoneNumberController.text.trim() &&
          user.instagram == instagramController.text.trim() &&
          user.facebook == facebookController.text.trim() &&
          user.website == websiteController.text.trim();
    } catch (e) {
      return false;
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
            child: FlatButton(
              //onPressed: checkFields() ? null : () => updateProfileData(),
              onPressed: () => updateProfileData(),
              child: Text(
                'UPDATE',
                style: TextStyle(
                  //color: checkFields() ? Colors.white38 : Colors.white,
                  color: Colors.white,
                  fontFamily: fontName,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // child: IconButton(
            //   icon: Icon(
            //     Icons.save,
            //     color: checkFields() ? Colors.white38 : Colors.white,
            //   ),
            //   onPressed: checkFields() ? null : updateProfileData,
            // ),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ConnectivityScreenWrapper(
        child: isLoading
            ? ProfileDashboardShimmer()
            : ListView(
                scrollDirection: Axis.vertical,
                children: [
                  Container(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
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
                                  radius: 70.0,
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
                        SizedBox(height: 20),
                        ExpansionTile(
                          initiallyExpanded: true,
                          leading: Icon(Icons.info),
                          title: Text('Basic information'),
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  right: 20, left: 20, bottom: 20),
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
                        ExpansionTile(
                          leading: Icon(Icons.info),
                          title: Text('Contacts'),
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  right: 20, left: 20, bottom: 20),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    title: Text("Show contacts to everyone"),
                                    value: showContacts,
                                    onChanged: (value) {
                                      setState(() {
                                        showContacts = !showContacts;
                                        finalShowContacts = value;
                                      });
                                    },
                                  ),
                                  buildEmailField(),
                                  buildPhoneNumberField(),
                                  buildInstagramField(),
                                  buildFacebookField(),
                                  buildWebsiteController(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Padding buildEmailField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        enabled: false,
        controller: emailController,
        style: TextStyle(
          fontFamily: fontName,
          color: Colors.grey,
        ),
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Email",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: user.email,
        ),
      ),
    );
  }

  Padding buildInstagramField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        controller: instagramController,
        style: TextStyle(fontFamily: fontName),
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Instagram",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input Instagram account",
        ),
      ),
    );
  }

  Padding buildFacebookField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        controller: facebookController,
        style: TextStyle(fontFamily: fontName),
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Facebook",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input Facebook username",
        ),
      ),
    );
  }

  Padding buildWebsiteController() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        controller: websiteController,
        style: TextStyle(fontFamily: fontName),
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Website",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input website URL",
        ),
      ),
    );
  }

  Padding buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        controller: phoneNumberController,
        keyboardType: TextInputType.phone,
        style: TextStyle(fontFamily: fontName),
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Phone Number",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input phone number",
        ),
      ),
    );
  }
}
