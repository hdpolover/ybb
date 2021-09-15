import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybb/helpers/api/summit_participant.dart';
import 'package:ybb/helpers/api/summit_participant_details.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/dialog.dart';

class SummitRegister5 extends StatefulWidget {
  @override
  _SummitRegister5State createState() => _SummitRegister5State();
}

class _SummitRegister5State extends State<SummitRegister5> {
  int progress;

  File imageFile;
  bool isAgreed = false;

  final GlobalKey<State> _key = GlobalKey<State>();

  String fullName,
      birthdate,
      address,
      gender,
      nationality,
      occupation,
      fieldOfStudy,
      institution,
      waNumber,
      igAccount,
      emergencyContact,
      contactRelation,
      diseaseHistory,
      tshirtSizeValue,
      vegetarianValue,
      experiences,
      achievements,
      socialProjects,
      talents,
      essay,
      subthemeValue,
      sourceName,
      sourcesValue,
      videoLink,
      proofLink,
      referralCode;

  @override
  void initState() {
    super.initState();

    getProgress();
  }

  getProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // sourceNameController.text = prefs.getString("source_account_name");
    // sourcesValue = prefs.getString("know_program_from");
    // videoLinkController.text = prefs.getString("video_link");

    progress = prefs.getInt("filledCount");
  }

  Padding buildIntroField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Self Photo",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            "(5/5)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Padding buildPhotoField() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Container(
            height: 250,
            width: 190,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(
                  image: imageFile == null
                      ? AssetImage('assets/images/default_photo.jpg')
                      : FileImage(imageFile),
                  fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              getImage();
            },
            child: Container(
              height: 40.0,
              width: MediaQuery.of(context).size.width * 0.3,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: RichText(
              softWrap: true,
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: fontName,
                    ),
                  ),
                  TextSpan(
                    text:
                        'choose a formal photo of yourself with an image ratio of 3:4 (preferably). The cropped preview image does not affect the original image.',
                    style: TextStyle(
                      fontFamily: fontName,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: isAgreed,
                activeColor: Colors.blue,
                onChanged: (bool value) {
                  setState(() {
                    isAgreed = value;
                  });
                },
              ),
              Expanded(
                child: Text(
                  "I understand and agree to the terms and conditions of this program and that this program basically is self funded meaning that participants have to pay for the program fee, flights to-from Istanbul, visa and other expenses themselves.  However best applicants have a chance to be a fully-funded participant (excluding flight tickets and visa). Fully-funded quota will refer to the quality of the applicants themselves. I am ready to join the 5th Istanbul Youth Summit!",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontFamily: fontName,
                    letterSpacing: 0.7,
                    color: isAgreed ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    File compressedImage = await compressFile(File(pickedFile.path));
    if (pickedFile != null) {
      setState(() {
        // imageFile = File(pickedFile.path);
        imageFile = compressedImage;
      });
    }
  }

  Future<File> compressFile(File file) async {
    final filePath = file.absolute.path;
    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 50,
    );
    print(file.lengthSync());
    print(result.lengthSync());
    return result;
  }

  checkForms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      fullName = prefs.getString("full_name");
      birthdate = prefs.getString("birthdate");
      address = prefs.getString("address");
      gender = prefs.getString("gender");
      nationality = prefs.getString("nationality");
      occupation = prefs.getString("occupation");
      fieldOfStudy = prefs.getString("field_of_study");
      institution = prefs.getString("institution");
      waNumber = prefs.getString("wa_number");
      igAccount = prefs.getString("ig_account");
      emergencyContact = prefs.getString("emergency_contact");
      contactRelation = prefs.getString("contact_relation");
      diseaseHistory = prefs.getString("disease_history");
      tshirtSizeValue = prefs.getString("tshirt_size");
      vegetarianValue = prefs.getString("vegetarian");
      experiences = prefs.getString("experiences");
      achievements = prefs.getString("achievements");
      socialProjects = prefs.getString("social_projects");
      talents = prefs.getString("talents");
      essay = prefs.getString("essay");
      subthemeValue = prefs.getString("subtheme");
      sourceName = prefs.getString("source_account_name");
      sourcesValue = prefs.getString("know_program_from");
      videoLink = prefs.getString("video_link");
      proofLink = prefs.getString("proof_link");
      referralCode = prefs.getString("referral_code");
    });

    if (fullName.trim().isNotEmpty &&
        birthdate.trim().isNotEmpty &&
        address.trim().isNotEmpty &&
        nationality.trim().isNotEmpty &&
        occupation.trim().isNotEmpty &&
        fieldOfStudy.trim().isNotEmpty &&
        gender.trim().isNotEmpty &&
        institution.trim().isNotEmpty &&
        waNumber.trim().isNotEmpty &&
        igAccount.trim().isNotEmpty &&
        emergencyContact.trim().isNotEmpty &&
        contactRelation.trim().isNotEmpty &&
        diseaseHistory.trim().isNotEmpty &&
        tshirtSizeValue.trim().isNotEmpty &&
        vegetarianValue.trim().isNotEmpty &&
        experiences.trim().isNotEmpty &&
        achievements.trim().isNotEmpty &&
        socialProjects.trim().isNotEmpty &&
        talents.trim().isNotEmpty &&
        essay.trim().isNotEmpty &&
        subthemeValue.trim().isNotEmpty &&
        sourceName.trim().isNotEmpty &&
        sourcesValue.trim().isNotEmpty &&
        videoLink.trim().isNotEmpty &&
        proofLink.trim().isNotEmpty &&
        imageFile != null) {
      if (referralCode.trim().isEmpty) {
        setState(() {
          referralCode = "-";
        });

        showConfirmDialog(context);
      } else {
        showConfirmDialog(context);
      }

      // Fluttertoast.showToast(
      //   msg: "Ready to submit",
      //   toastLength: Toast.LENGTH_LONG,
      //   timeInSecForIosWeb: 1,
      // );
    } else {
      Fluttertoast.showToast(
        msg:
            "Some fields are still empty. Please fill them out before continuing.",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
      );
    }
  }

  Future<void> showConfirmDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Submission',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "OpenSans",
              letterSpacing: 1,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  'You are about to submit the registration form. You will not be able to edit your data. Make sure everything is correct. Are you sure to continue?',
                  style: TextStyle(
                    fontFamily: fontName,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.red,
              textColor: Colors.white,
              child: Text('YES, I AM SURE'),
              onPressed: () async {
                Dialogs.showLoadingDialog(context, _key);

                int veg = 0;
                if (vegetarianValue == "Yes") {
                  veg = 1;
                } else {
                  veg = 0;
                }

                Map<String, dynamic> data = {
                  'id_participant': currentUser.id,
                  'full_name': fullName,
                  'birthdate': birthdate,
                  'gender': gender,
                  'nationality': nationality,
                  'address': address,
                  'occupation': occupation,
                  'field_of_study': fieldOfStudy,
                  'ig_account': igAccount,
                  'wa_number': waNumber,
                  'institution': institution,
                  'is_vegetarian': veg,
                  'contact_relation': contactRelation,
                  'talents': talents,
                  'tshirt_size': tshirtSizeValue,
                  'disease_history': diseaseHistory,
                  'emergency_contact': emergencyContact,
                  'essay': essay,
                  'experiences': experiences,
                  'social_projects': socialProjects,
                  'source_account_name': sourceName,
                  'know_program_from': sourcesValue,
                  'achievements': achievements,
                  'subtheme': subthemeValue,
                  'video_link': videoLink,
                  'referral_code': referralCode,
                };

                print(referralCode);

                try {
                  await SummitParticipantDetails.addParticipantDetails(
                      data, imageFile);

                  await SummitParticipant.updateParticipantStatus(
                      currentUser.id, "1");

                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  Fluttertoast.showToast(
                    msg: "Success! Pull down to refresh page.",
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 1,
                  );
                } on Exception catch (e) {
                  print(e);
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pop();
                  Fluttertoast.showToast(
                      msg: "An error occured! Please try again later.",
                      toastLength: Toast.LENGTH_LONG,
                      timeInSecForIosWeb: 1);
                }
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('NO, NOT NOW'),
              onPressed: () {
                print('Confirmed');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        title: Text(
          "Registration Form",
          style: appBarTextStyle,
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        scrollDirection: Axis.vertical,
        children: [
          buildIntroField(),
          buildPhotoField(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          GestureDetector(
            // onTap: isAgreed
            //     ? () {
            //         checkForms();
            //       }
            //     : () {},
            onTap: () {
              checkForms();
            },
            child: Container(
              height: 50.0,
              width: 350.0,
              decoration: BoxDecoration(
                color: isAgreed ? Colors.blue : Colors.grey,
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
        ],
      ),
    );
  }
}
