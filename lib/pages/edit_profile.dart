import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;

  FocusNode focusNode;
  FocusNode focusNode1;

  @override
  void initState() {
    super.initState();
    getUser();

    focusNode = FocusNode();
    focusNode1 = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    focusNode1.dispose();

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
          focusNode: focusNode1,
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update bio",
            errorText: _bioValid ? null : "Bio is too long",
          ),
        ),
      ],
    );
  }

  updateProfileData() {
    focusNode.unfocus();
    focusNode1.unfocus();

    setState(() {
      displayNameController.text.trim().length < 5 ||
              displayNameController.text.trim().isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;

      bioController.text.trim().length > 50
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });

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
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Montserrat",
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: updateProfileData,
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16.9),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            buildDisplayNameField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Column buildDisplayNameField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Padding(
  //           padding: EdgeInsets.only(top: 12.0),
  //           child: Text(
  //             "Display Name",
  //             style: TextStyle(color: Colors.grey),
  //           )),
  //       TextField(
  //         controller: displayNameController,
  //         decoration: InputDecoration(
  //           hintText: "Update Display Name",
  //           errorText: _displayNameValid ? null : "Display Name too short",
  //         ),
  //       )
  //     ],
  //   );
  // }

  // Column buildBioField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Padding(
  //         padding: EdgeInsets.only(top: 12.0),
  //         child: Text(
  //           "Bio",
  //           style: TextStyle(color: Colors.grey),
  //         ),
  //       ),
  //       TextField(
  //         controller: bioController,
  //         decoration: InputDecoration(
  //           hintText: "Update Bio",
  //           errorText: _bioValid ? null : "Bio too long",
  //         ),
  //       )
  //     ],
  //   );
  // }

  // updateProfileData() {
  //   setState(() {
  //     displayNameController.text.trim().length < 3 ||
  //             displayNameController.text.isEmpty
  //         ? _displayNameValid = false
  //         : _displayNameValid = true;
  //     bioController.text.trim().length > 100
  //         ? _bioValid = false
  //         : _bioValid = true;
  //   });

  //   if (_displayNameValid && _bioValid) {
  //     usersRef.doc(widget.currentUserId).update({
  //       "displayName": displayNameController.text,
  //       "bio": bioController.text,
  //     });
  //     SnackBar snackbar = SnackBar(content: Text("Profile updated!"));
  //     _scaffoldKey.currentState.showSnackBar(snackbar);
  //   }
  // }

  // logout() async {
  //   await googleSignIn.signOut();
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     key: _scaffoldKey,
  //     appBar: AppBar(
  //       backgroundColor: Colors.white,
  //       title: Text(
  //         "Edit Profile",
  //         style: TextStyle(
  //           color: Colors.black,
  //         ),
  //       ),
  //       actions: <Widget>[
  //         IconButton(
  //           onPressed: () => Navigator.pop(context),
  //           icon: Icon(
  //             Icons.done,
  //             size: 30.0,
  //             color: Colors.green,
  //           ),
  //         ),
  //       ],
  //     ),
  //     body: isLoading
  //         ? circularProgress()
  //         : ListView(
  //             children: <Widget>[
  //               Container(
  //                 child: Column(
  //                   children: <Widget>[
  //                     Padding(
  //                       padding: EdgeInsets.only(
  //                         top: 16.0,
  //                         bottom: 8.0,
  //                       ),
  //                       child: CircleAvatar(
  //                         radius: 50.0,
  //                         backgroundImage:
  //                             CachedNetworkImageProvider(user.photoUrl),
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.all(16.0),
  //                       child: Column(
  //                         children: <Widget>[
  //                           buildDisplayNameField(),
  //                           buildBioField(),
  //                         ],
  //                       ),
  //                     ),
  //                     RaisedButton(
  //                       onPressed: updateProfileData,
  //                       child: Text(
  //                         "Update Profile",
  //                         style: TextStyle(
  //                           color: Theme.of(context).primaryColor,
  //                           fontSize: 20.0,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.all(16.0),
  //                       child: FlatButton.icon(
  //                         onPressed: logout,
  //                         icon: Icon(Icons.cancel, color: Colors.red),
  //                         label: Text(
  //                           "Logout",
  //                           style: TextStyle(color: Colors.red, fontSize: 20.0),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //   );
  // }
}