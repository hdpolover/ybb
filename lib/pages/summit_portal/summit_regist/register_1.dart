import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/summit_portal/summit_regist/register_2.dart';

class SummitRegister1 extends StatefulWidget {
  @override
  _SummitRegister1State createState() => _SummitRegister1State();
}

class _SummitRegister1State extends State<SummitRegister1> {
  TextEditingController fullnameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController institutionController = TextEditingController();
  TextEditingController fieldOfStudyController = TextEditingController();
  TextEditingController waNumberController = TextEditingController();
  TextEditingController emergencyContactController = TextEditingController();
  TextEditingController diseaseHistoryController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
  TextEditingController contactRelationController = TextEditingController();
  TextEditingController igAccountController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    fullnameController.dispose();
    addressController.dispose();
    occupationController.dispose();
    institutionController.dispose();
    fieldOfStudyController.dispose();
    waNumberController.dispose();
    emergencyContactController.dispose();
    diseaseHistoryController.dispose();
    birthdateController.dispose();
    nationalityController.dispose();
    contactRelationController.dispose();
    igAccountController.dispose();
  }

  List<DropdownMenuItem<String>> _tshirtSizeDropdownItems;
  String tshirtSizeValue;
  List<DropdownMenuItem<String>> _vegetarianDropdownItems;
  String vegetarianValue;
  List<DropdownMenuItem<String>> _genderDropdownItems;
  String genderValue;

  String dateTime;
  DateTime selectedDate = DateTime.now();

  int progress = 0;

//edit profile stuff
  List _tshirtSizes = [
    "S",
    "M",
    "L",
    "XL",
    "XXL",
    "XXXL",
  ];

  List _vegetarians = [
    "Yes",
    "No",
  ];

  List _genders = [
    "Male",
    "Female",
  ];

  @override
  void initState() {
    super.initState();

    getProgress();

    _tshirtSizeDropdownItems = getDropDownMenuItems(_tshirtSizes);
    _vegetarianDropdownItems = getDropDownMenuItems(_vegetarians);
    _genderDropdownItems = getDropDownMenuItems(_genders);
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List selected) {
    List<DropdownMenuItem<String>> items = new List();
    for (String x in selected) {
      items.add(new DropdownMenuItem(value: x, child: new Text(x)));
    }
    return items;
  }

  Padding buildFullnameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: fullnameController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Full name",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input your full name",
        ),
      ),
    );
  }

  Padding buildOccupationField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: occupationController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Occupation",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Specify your current occupation",
        ),
      ),
    );
  }

  Padding buildWaNumberField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: waNumberController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "WhatsApp Number",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Include the country code, e.g 62XXX",
        ),
      ),
    );
  }

  Padding buildFieldOfStudyField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: fieldOfStudyController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Field of Study",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Specify your field of study",
        ),
      ),
    );
  }

  Padding buildIgAccountField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: igAccountController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Instagram Account",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Specify your instagram account username",
        ),
      ),
    );
  }

  Padding buildInstitutionField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: institutionController,
        maxLines: 2,
        minLines: 1,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Institution/Workplace",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Specify your instituion/workplace",
        ),
      ),
    );
  }

  Padding buildContactRelationField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: contactRelationController,
        keyboardType: TextInputType.text,
        minLines: 1,
        maxLines: 2,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Contact Relation",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Specify your relation with the emergency contact holder",
        ),
      ),
    );
  }

  Padding buildAddressField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: addressController,
        minLines: 2,
        maxLines: 5,
        keyboardType: TextInputType.streetAddress,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Address",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input your current address",
        ),
      ),
    );
  }

  Padding buildDiseaseHistoryField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: diseaseHistoryController,
        minLines: 1,
        maxLines: 3,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Disease History",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input (-) if there is none",
        ),
      ),
    );
  }

  Padding buildEmergencyContactField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: emergencyContactController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Emergency Contact",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Include the country code, e.g +62XXX",
        ),
      ),
    );
  }

  Padding buildBirthdateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        readOnly: true,
        controller: birthdateController,
        onTap: () async {
          var date = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now());

          setState(() {
            birthdateController.text = DateFormat('yyyy-MM-dd').format(date);
          });
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Birthdate",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Choose your birthdate",
        ),
      ),
    );
  }

  Padding buildNationalityField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        readOnly: true,
        controller: nationalityController,
        onTap: () async {
          showCountryPicker(
            context: context,
            exclude: <String>[
              'KN',
              'MF'
            ], //It takes a list of country code(iso2).
            showPhoneCode: false,
            onSelect: (Country country) =>
                nationalityController.text = country.displayNameNoCountryCode,
          );
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Nationality",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Choose your nationality",
        ),
      ),
    );
  }

  Padding buildTshirtSizeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "T-shirt Size",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
              fontSize: 16,
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
                style: TextStyle(
                  fontFamily: fontName,
                  color: Colors.black,
                ),
                hint: Text("Select t-shirt size"),
                value: tshirtSizeValue,
                items: _tshirtSizeDropdownItems,
                onChanged: (value) {
                  setState(() {
                    tshirtSizeValue = value;
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
        ],
      ),
    );
  }

  Padding buildVegetarianField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Are you a vegetarian?",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
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
                style: TextStyle(
                  fontFamily: fontName,
                  color: Colors.black,
                ),
                hint: Text("Choose one"),
                value: vegetarianValue,
                items: _vegetarianDropdownItems,
                onChanged: (value) {
                  setState(() {
                    vegetarianValue = value;
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
        ],
      ),
    );
  }

  Padding buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Gender",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
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
                style: TextStyle(
                  fontFamily: fontName,
                  color: Colors.black,
                ),
                hint: Text("Select gender"),
                value: genderValue,
                items: _genderDropdownItems,
                onChanged: (value) {
                  setState(() {
                    genderValue = value;
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
        ],
      ),
    );
  }

  Padding buildIntroField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Basic Information",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            "(1/5)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("full_name", fullnameController.text.trim());
    prefs.setString("birthdate", birthdateController.text.trim());
    prefs.setString("gender", genderValue);
    prefs.setString("address", addressController.text.trim());
    prefs.setString("nationality", nationalityController.text.trim());
    prefs.setString("occupation", occupationController.text.trim());
    prefs.setString("field_of_study", fieldOfStudyController.text.trim());
    prefs.setString("institution", institutionController.text.trim());
    prefs.setString("wa_number", waNumberController.text.trim());
    prefs.setString("ig_account", igAccountController.text.trim());
    prefs.setString(
        "emergency_contact", emergencyContactController.text.trim());
    prefs.setString("contact_relation", contactRelationController.text.trim());
    prefs.setString("disease_history", diseaseHistoryController.text.trim());
    prefs.setString("tshirt_size", tshirtSizeValue);
    prefs.setString("vegetarian", vegetarianValue);

    //set form filled
    if (progress == 0 || progress == null) {
      prefs.setInt("filledCount", 2);
    }

    print(prefs.getInt("filledCount").toString());
  }

  getProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    fullnameController.text = prefs.getString("full_name");
    birthdateController.text = prefs.getString("birthdate");
    addressController.text = prefs.getString("address");
    nationalityController.text = prefs.getString("nationality");
    occupationController.text = prefs.getString("occupation");
    fieldOfStudyController.text = prefs.getString("field_of_study");
    institutionController.text = prefs.getString("institution");
    waNumberController.text = prefs.getString("wa_number");
    igAccountController.text = prefs.getString("ig_account");
    emergencyContactController.text = prefs.getString("emergency_contact");
    contactRelationController.text = prefs.getString("contact_relation");
    diseaseHistoryController.text = prefs.getString("disease_history");

    setState(() {
      tshirtSizeValue = prefs.getString("tshirt_size");
      vegetarianValue = prefs.getString("vegetarian");
      genderValue = prefs.getString("gender");
      try {
        progress = prefs.getInt("filledCount" ?? 0);
      } catch (e) {
        progress = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        saveProgress();

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              saveProgress();
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Registration Form",
            style: appBarTextStyle,
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.archive),
                onPressed: () {
                  saveProgress();

                  Fluttertoast.showToast(
                      msg: "Form drafted",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 1);
                  Navigator.of(context).pop();
                }),
          ],
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          scrollDirection: Axis.vertical,
          children: [
            buildIntroField(),
            buildFullnameField(),
            buildBirthdateField(),
            buildGenderField(),
            buildAddressField(),
            buildNationalityField(),
            buildOccupationField(),
            buildFieldOfStudyField(),
            buildInstitutionField(),
            buildWaNumberField(),
            buildIgAccountField(),
            buildEmergencyContactField(),
            buildContactRelationField(),
            buildDiseaseHistoryField(),
            buildTshirtSizeField(),
            buildVegetarianField(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            GestureDetector(
              onTap: () {
                saveProgress();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummitRegister2(),
                  ),
                );
              },
              child: Container(
                height: 50.0,
                width: 350.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Center(
                  child: Text(
                    "NEXT PAGE",
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
      ),
    );
  }
}
