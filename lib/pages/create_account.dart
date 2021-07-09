import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateAccount extends StatefulWidget {
  final String currentUserId;

  CreateAccount({this.currentUserId});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController occupation = new TextEditingController();
  TextEditingController interests = new TextEditingController();
  TextEditingController bio = new TextEditingController();

  bool _occupationValid = false;
  bool _interestValid = false;
  bool _bioValid = false;

  List<String> inters;

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
  String residenceString = "-";
  bool isLocationBtnPressed = false;

  String latitude;
  String longitude;

  @override
  void initState() {
    super.initState();
    residenceString = "-";
    _occupationDropItems = getDropDownMenuItems(_occupations);
    //mainOccupation = _occupationDropItems[0].value;
    _interestDropItems = getDropDownMenuItems(_interests);
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List selected) {
    List<DropdownMenuItem<String>> items = new List();
    for (String x in selected) {
      items.add(new DropdownMenuItem(value: x, child: new Text(x)));
    }
    return items;
  }

  updateProfileData() async {
    if (occupation.text.trim().length > 5) {
      _occupationValid = true;
    } else {
      _occupationValid = false;
    }

    if (interests.text.trim().length > 5) {
      _interestValid = true;
    } else {
      _interestValid = false;
    }

    if (bio.text.trim().length > 5) {
      _bioValid = true;
    } else {
      _bioValid = false;
    }

    if (_occupationValid || _interestValid || _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "occupation": occupation.text,
        "interests": interests.text,
        "bio": bio.text,
        "mainOccupation": mainOccupation,
        "mainInterest": mainInterest,
        "birthdate": _birthdateController.text,
        "residence": _currentAddress,
        "latitude": latitude,
        "longitude": longitude,
      });

      SnackBar snackBar = SnackBar(
        content: Text("Profile successfully created!"),
        duration: Duration(seconds: 2),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);

      Timer(
        Duration(seconds: 2),
        () {
          Navigator.of(context).pop();
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Please fill the fields! Minimum 5 characters.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
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
                        residenceString == "-"
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
            controller: occupation,
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
            controller: interests,
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
        controller: bio,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext parentContext) {
    return WillPopScope(
      onWillPop: () async {
        Fluttertoast.showToast(
          msg: 'Please complete your profile!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );

        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        //appBar: defaultAppBar(context, titleText: "User Details", removeBackButton: true),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Center(
                        child: Text(
                          "Let others know you by completing these",
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Montserrat",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SvgPicture.asset(
                      'assets/images/info_data.svg',
                      height: 170,
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          buildBirthdateField(),
                          buildOccupationFields(),
                          buildInterestFields(),
                          buildResidenceField(),
                          buildBioField(),
                          FlatButton(
                            height: 50.0,
                            minWidth: MediaQuery.of(context).size.width,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                            onPressed: () => {updateProfileData()},
                            color: Colors.blue,
                            child: Text(
                              "SAVE",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Padding(
                    //   padding: EdgeInsets.all(16.0),
                    //   child: Container(
                    //     child: Column(
                    //       children: [
                    //         TextFormField(
                    //           controller: occupation,
                    //           decoration: InputDecoration(
                    //             border: OutlineInputBorder(),
                    //             labelText: "Occupation",
                    //             labelStyle: TextStyle(fontSize: 15.0),
                    //             hintText: "Input your current occupation",
                    //           ),
                    //         ),
                    //         SizedBox(height: 15),
                    //         TextFormField(
                    //           controller: interests,
                    //           decoration: InputDecoration(
                    //             border: OutlineInputBorder(),
                    //             labelText: "Interest(s)",
                    //             labelStyle: TextStyle(fontSize: 15.0),
                    //             hintText: "If more than one, separate with a comma",
                    //           ),
                    //         ),
                    //         SizedBox(height: 15),
                    //         TextFormField(
                    //           controller: bio,
                    //           minLines: 3,
                    //           maxLines: 10,
                    //           decoration: InputDecoration(
                    //             border: OutlineInputBorder(),
                    //             labelText: "Bio",
                    //             labelStyle: TextStyle(fontSize: 15.0),
                    //             hintText: "Write something about yourself",
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // GestureDetector(
                    //   onTap: updateProfileData,
                    //   child: Container(
                    //     height: 50.0,
                    //     width: 350.0,
                    //     decoration: BoxDecoration(
                    //       color: Colors.blue,
                    //       borderRadius: BorderRadius.circular(7.0),
                    //     ),
                    //     child: Center(
                    //       child: Text(
                    //         "CONTINUE",
                    //         style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 15.0,
                    //             fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 20),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
