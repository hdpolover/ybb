import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:image/image.dart' as Im;
import 'package:http/http.dart' as http;
import 'package:ybb/widgets/shimmers/profile_dashboard_shimmer_layout.dart';

import 'package:ybb/models/user_recoms.dart';

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

  //edit profile stuff
  List _occupations = [
    "Student",
    "Employed",
    "Unemployed",
  ];

  List _interests = [
    "Education",
    "Travel",
    "Entertainment",
    "Technology",
    "Health and Fitness",
    "Science and Nature",
    "Other/Everything",
  ];

  List<DropdownMenuItem<String>> _occupationDropItems;
  String mainOccupation;
  List<DropdownMenuItem<String>> _interestDropItems;
  String mainInterest;

  TextEditingController _birthdateController = TextEditingController();
  TextEditingController _residenceController = TextEditingController();

  String dateTime;
  DateTime selectedDate = DateTime.now();

  Position _currentPosition;
  String _currentAddress;
  Future<String> residence;
  String residenceString;
  bool isLocationBtnPressed = false;

  int follows = 0;
  String latitude;
  String longitude;

  @override
  void initState() {
    super.initState();

    _occupationDropItems = getDropDownMenuItems(_occupations);
    //mainOccupation = _occupationDropItems[0].value;
    _interestDropItems = getDropDownMenuItems(_interests);
    //mainInterest = _interestDropItems[0].value;

    getUser();
    getFollowCount();
    getAllUsernames();

    focusNode = FocusNode();
    focusNode1 = FocusNode();
    focusNode2 = FocusNode();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List selected) {
    List<DropdownMenuItem<String>> items = new List();
    for (String x in selected) {
      items.add(new DropdownMenuItem(value: x, child: new Text(x)));
    }
    return items;
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
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    //user = AppUser.fromDocument(doc);
    try {
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

      _birthdateController.text = user.birthdate;
      _currentAddress = user.residence;

      switch (user.mainOccupation) {
        case "Student":
          mainOccupation = _occupationDropItems[0].value;
          break;
        case "Employed":
          mainOccupation = _occupationDropItems[1].value;
          break;
        case "Unemployed":
          mainOccupation = _occupationDropItems[2].value;
          break;
      }

      switch (user.mainInterest) {
        case "Education":
          mainInterest = _interestDropItems[0].value;
          break;
        case "Travel":
          mainInterest = _interestDropItems[1].value;
          break;
        case "Entertainment":
          mainInterest = _interestDropItems[2].value;
          break;
        case "Technology":
          mainInterest = _interestDropItems[3].value;
          break;
        case "Health and Fitness":
          mainInterest = _interestDropItems[4].value;
          break;
        case "Science and Nature":
          mainInterest = _interestDropItems[5].value;
          break;
        case "Other/Everything":
          mainInterest = _interestDropItems[6].value;
          break;
      }

      setState(() {
        isLoading = false;
        currentUsername = user.username;
        residenceString = user.residence;
        latitude = user.latitude;
        longitude = user.longitude;
      });
    } catch (e) {
      user = AppUser(
        id: doc['id'],
        email: doc['email'],
        username: doc['username'],
        photoUrl: doc['photoUrl'],
        displayName: doc['displayName'],
        bio: doc['bio'],
        occupation: doc['occupation'],
        interests: doc['interests'],
        registerDate: doc['registerDate'].toDate(),
        phoneNumber: doc['phoneNumber'],
        showContacts: doc['showContacts'],
        instagram: doc['instagram'],
        facebook: doc['facebook'],
        website: doc['website'],
      );

      setState(() {
        isLoading = false;
        currentUsername = user.username;
      });
    }
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

  buildBirthdateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: TextFormField(
        readOnly: true,
        controller: _birthdateController,
        onTap: () async {
          var date = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now());

          setState(() {
            _birthdateController.text = DateFormat('yyyy-MM-dd').format(date);
          });
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Birthdate",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Specify your birthdate",
        ),
      ),
    );
  }

  _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.administrativeArea}, ${place.country}";
        _residenceController.text = _currentAddress;

        latitude = _currentPosition.latitude.toString();
        longitude = _currentPosition.longitude.toString();

        residence = Future<String>.value(_currentAddress);
      });
    } catch (e) {
      print(e);
    }
  }

  buildResidenceField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Residence",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.fromLTRB(15, 5, 10, 5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isLocationBtnPressed
                    ? FutureBuilder(
                        future: residence,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text(
                              "Fetching location...",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            );
                          }

                          return Text(
                            snapshot.data.length > 25
                                ? snapshot.data.substring(0, 24) + "..."
                                : snapshot.data,
                          );
                        },
                      )
                    : Text(
                        residenceString == null
                            ? "No residence specified"
                            : residenceString == "-"
                                ? "No residence specified"
                                : residenceString,
                        style: TextStyle(
                          fontFamily: fontName,
                          color: residenceString == "-"
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                FlatButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  color: Colors.blue,
                  icon: Icon(
                    Icons.location_pin,
                    semanticLabel: "Get location",
                    color: Colors.white,
                  ),
                  label: Text(
                    residenceString == "-" ? "Locate me" : "Relocate me",
                    style: TextStyle(
                      fontFamily: fontName,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isLocationBtnPressed = true;
                    });
                    _getCurrentLocation();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildOccupationFields() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Occupation",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                style: TextStyle(
                  fontFamily: fontName,
                  color: Colors.black,
                ),
                hint: Text("Select occupation"),
                value: mainOccupation,
                items: _occupationDropItems,
                onChanged: (value) {
                  setState(() {
                    mainOccupation = value;
                  });
                },
                elevation: 6,
                icon: Icon(
                  Icons.arrow_drop_down_circle,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            style: TextStyle(fontFamily: fontName),
            controller: occupationController,
            minLines: 1,
            maxLines: 2,
            maxLength: 50,
            decoration: InputDecoration(
              hintStyle: TextStyle(fontFamily: fontName),
              errorStyle: TextStyle(fontFamily: fontName),
              border: OutlineInputBorder(),
              labelText: "Specified occupation",
              labelStyle: TextStyle(fontFamily: fontName),
              hintText: "Specify your current occupation",
              errorText: _occupationValid ? null : "Occupation is not valid",
            ),
          ),
        ],
      ),
    );
  }

  buildInterestFields() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interest",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                style: TextStyle(
                  fontFamily: fontName,
                  color: Colors.black,
                ),
                hint: Text("Select interest"),
                value: mainInterest,
                items: _interestDropItems,
                onChanged: (value) {
                  setState(() {
                    mainInterest = value;
                  });
                },
                elevation: 6,
                icon: Icon(
                  Icons.arrow_drop_down_circle,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            style: TextStyle(fontFamily: fontName),
            controller: interestController,
            minLines: 1,
            maxLines: 2,
            maxLength: 50,
            decoration: InputDecoration(
              hintStyle: TextStyle(fontFamily: fontName),
              errorStyle: TextStyle(fontFamily: fontName),
              border: OutlineInputBorder(),
              labelText: "Specified interest",
              labelStyle: TextStyle(fontFamily: fontName),
              hintText: "Specify your current interest",
              errorText: _occupationValid ? null : "Interesy is not valid",
            ),
          ),
        ],
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
      usersRef.doc(widget.currentUserId).update(
        {
          "displayName": displayNameController.text.trim(),
          "bio": bioController.text.trim(),
          "username": usernameController.text.trim(),
          "occupation": occupationController.text.trim(),
          "interests": interestController.text.trim(),
          "photoUrl": mediaUrl,
          "dnSearchKey":
              displayNameController.text.substring(0, 1).toUpperCase(),
          "instagram": instagramController.text.trim(),
          "phoneNumber": phoneNumberController.text.trim(),
          "facebook": facebookController.text.trim(),
          "website": websiteController.text.trim(),
          "showContacts": showContacts,
          "mainOccupation": mainOccupation,
          "mainInterest": mainInterest,
          "birthdate": _birthdateController.text,
          "residence": _currentAddress,
          "latitude": latitude,
          "longitude": longitude,
        },
      );

      clearImageAndBack();

      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.blue,
        content: Text("Profile successfully updated!"),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);

      await getUserRecommends();
      //Navigator.pop(context);
      // Timer(
      //   Duration(seconds: 2),
      //   () {
      //     Navigator.of(context).pop();
      //   },
      // );
    } else {
      return;
    }
  }

  getFollowCount() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();

    List<String> followingList = snapshot.docs.map((doc) => doc.id).toList();

    QuerySnapshot snapshot1 = await followersRef
        .doc(currentUser.id)
        .collection('userFollowers')
        .get();

    List<String> followersList = snapshot1.docs.map((doc) => doc.id).toList();

    setState(() {
      follows = followersList.length + followingList.length;
    });
  }

  getUserRecommends() async {
    String userId = user.id;
    String userInterest = mainInterest.toLowerCase();
    String userOccupation = mainOccupation.toLowerCase();
    String userBirthdate = _birthdateController.text;
    String userFollowCount = follows.toString();
    String userLatitude = latitude;
    String userLongitude = longitude;

    var data = [
      userId,
      userInterest,
      userOccupation,
      userBirthdate,
      userFollowCount,
      userLatitude,
      userLongitude,
    ];

    await getFilteringResult(data);
  }

  Future<void> getFilteringResult(List<String> userData) async {
    var data = json.encode({
      'userId': userData[0],
      'interest': userData[1],
      'occupation': userData[2],
      'birthdate': userData[3],
      'follow_count': userData[4],
      'latitude': userData[5],
      'longitude': userData[6],
    });

    const url = 'http://hdpolover.pythonanywhere.com/api';
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: data,
    );

    if (response.statusCode == 200) {
      UserRecoms userIds;
      var jsonData = jsonDecode(response.body);
      jsonData.forEach((e) {
        userIds = UserRecoms(
          ids: e['ids'],
          similarities: e['similarities'],
        );
      });

      List<String> userIdList = userIds.ids.map((s) => s as String).toList();
      List<double> similarityList =
          userIds.similarities.map((s) => s as double).toList();

      for (int i = 0; i < userIdList.length; i++) {
        print(userIdList[i] + ": " + similarityList[i].toString());
      }

      //insert to firebase
      await setUserRecommendation(userIdList, similarityList);
    } else {
      print("error");
    }
  }

  setUserRecommendation(List<String> uids, List<double> similarities) async {
    //delete the previous recommendation
    QuerySnapshot a =
        await userRecomsRef.doc(currentUser.id).collection("userRecoms").get();

    List<String> b = a.docs.map((doc) => doc.id).toList();

    for (int i = 0; i < b.length; i++) {
      await userRecomsRef
          .doc(currentUser.id)
          .collection("userRecoms")
          .doc(b[i])
          .get()
          .then(
        (doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        },
      );
    }

    //add the new recommendation
    for (int i = 0; i < uids.length; i++) {
      await userRecomsRef
          .doc(user.id)
          .collection('userRecoms')
          .doc(uids[i])
          .set(
        {
          "userId": uids[i],
          "similarity": similarities[i],
        },
      );
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

  bool isPressed = false;

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
              onPressed: isPressed
                  ? null
                  : () {
                      updateProfileData();
                      setState(() {
                        isPressed = true;
                      });
                    },
              child: Text(
                'UPDATE',
                style: TextStyle(
                  //color: checkFields() ? Colors.white38 : Colors.white,
                  color: isPressed ? Colors.white38 : Colors.white,
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
                                  buildBirthdateField(),
                                  buildResidenceField(),
                                  buildOccupationFields(),
                                  buildInterestFields(),
                                  buildBioField(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          leading: Icon(Icons.info),
                          title: Text('Contacts'),
                          trailing: Icon(Icons.arrow_drop_down_circle),
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
