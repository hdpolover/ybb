import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/summit_portal/summit_regist/register_2.dart';

class SummitRegister1 extends StatefulWidget {
  @override
  _SummitRegister1State createState() => _SummitRegister1State();
}

class _SummitRegister1State extends State<SummitRegister1>
    with AutomaticKeepAliveClientMixin<SummitRegister1> {
  TextEditingController fullnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController institutionController = TextEditingController();
  TextEditingController fieldOfStudyController = TextEditingController();
  TextEditingController waNumberController = TextEditingController();
  TextEditingController emergencyContactController = TextEditingController();
  TextEditingController diseaseHistoryController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();

  List<DropdownMenuItem<String>> _tshirtSizeDropdownItems;
  String tshirtSizeValue;
  List<DropdownMenuItem<String>> _vegetarianDropdownItems;
  String vegetarianValue;

  String dateTime;
  DateTime selectedDate = DateTime.now();

//edit profile stuff
  List _tshirtSizes = [
    "S",
    "M",
    "L",
    "XL",
    "XXL",
  ];

  List _vegetarians = [
    "Yes",
    "No",
  ];

  @override
  void initState() {
    super.initState();

    _tshirtSizeDropdownItems = getDropDownMenuItems(_tshirtSizes);
    _vegetarianDropdownItems = getDropDownMenuItems(_vegetarians);
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List selected) {
    List<DropdownMenuItem<String>> items = new List();
    for (String x in selected) {
      items.add(new DropdownMenuItem(value: x, child: new Text(x)));
    }
    return items;
  }

  Padding buildEmailField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Email",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "example@email.com",
        ),
      ),
    );
  }

  Padding buildFullnameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: fullnameController,
        maxLines: 2,
        minLines: 1,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Full name",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input you full name",
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
        maxLines: 2,
        minLines: 1,
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
          hintText: "Include the country code, e.g +62XXX",
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
        maxLines: 2,
        minLines: 1,
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

  Padding buildInstitutionField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: institutionController,
        maxLines: 2,
        minLines: 1,
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

  Padding buildAddressField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: addressController,
        minLines: 2,
        maxLines: 5,
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

  bool get wantKeepAlive => true;

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
                hint: Text("Yes"),
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
            "(1/4)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Register",
          style: appBarTextStyle,
        ),
        actions: [
          IconButton(icon: Icon(Icons.archive), onPressed: () {}),
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
          buildEmailField(),
          buildFullnameField(),
          buildBirthdateField(),
          buildAddressField(),
          buildNationalityField(),
          buildOccupationField(),
          buildFieldOfStudyField(),
          buildInstitutionField(),
          buildWaNumberField(),
          buildEmergencyContactField(),
          buildDiseaseHistoryField(),
          buildTshirtSizeField(),
          buildVegetarianField(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          GestureDetector(
            onTap: () {
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
    );
  }
}
