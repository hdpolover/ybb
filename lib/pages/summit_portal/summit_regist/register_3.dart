import 'package:flutter/material.dart';
import 'package:ybb/helpers/constants.dart';

class SummitRegister3 extends StatefulWidget {
  @override
  _SummitRegister3State createState() => _SummitRegister3State();
}

class _SummitRegister3State extends State<SummitRegister3>
    with AutomaticKeepAliveClientMixin<SummitRegister3> {
  TextEditingController experiencesController = TextEditingController();
  TextEditingController achievementsController = TextEditingController();
  TextEditingController socialProjectsController = TextEditingController();
  TextEditingController talentsController = TextEditingController();

  List _subthemes = [
    "Economy",
    "Education",
    "Public Policy",
    "Mental Health",
  ];

  List<DropdownMenuItem<String>> _subthemesDropdownItems;
  String subthemeValue;

  @override
  void initState() {
    super.initState();

    _subthemesDropdownItems = getDropDownMenuItems(_subthemes);
  }

  bool get wantKeepAlive => true;

  List<DropdownMenuItem<String>> getDropDownMenuItems(List selected) {
    List<DropdownMenuItem<String>> items = new List();
    for (String x in selected) {
      items.add(new DropdownMenuItem(value: x, child: new Text(x)));
    }
    return items;
  }

  Padding buildEssayField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: experiencesController,
        minLines: 3,
        maxLines: 10,
        maxLength: 500,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Essay",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Write an essay of your chosen sub-theme.",
        ),
      ),
    );
  }

  Padding buildSubthemeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Sub-theme",
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
                hint: Text("Select a sub-theme"),
                value: subthemeValue,
                items: _subthemesDropdownItems,
                onChanged: (value) {
                  setState(() {
                    subthemeValue = value;
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
            "Essay",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            "(3/4)",
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
          buildSubthemeField(),
          buildEssayField(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SummitRegister3(),
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
