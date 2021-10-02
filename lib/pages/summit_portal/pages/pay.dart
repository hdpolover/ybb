import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ybb/helpers/api/payment.dart';
import 'package:ybb/helpers/api/summit.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/widgets/dialog.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class Pay extends StatefulWidget {
  final int summitId;
  final String type;
  final int paymentTypeId;

  Pay({
    @required this.summitId,
    @required this.type,
    @required this.paymentTypeId,
  });

  @override
  _PayState createState() => _PayState();
}

class _PayState extends State<Pay> {
  TextEditingController accountNameController = new TextEditingController();
  TextEditingController sourceNameController = new TextEditingController();
  TextEditingController paymentDateController = new TextEditingController();
  TextEditingController amountController = new TextEditingController();

  File imageFile;
  double paymentAmountIDR = 0;
  double paymentAmountUSD = 0;

  final GlobalKey<State> _key = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    getPaymentAmount();
  }

  @override
  void dispose() {
    accountNameController.dispose();
    sourceNameController.dispose();
    paymentDateController.dispose();
    amountController.dispose();
    super.dispose();
  }

  getPaymentAmount() async {
    List<Summit> s = await Summit.getSummitById(widget.summitId);

    double amount = 0;
    double usd = 0;
    if (widget.type == "regist_fee") {
      amount = double.parse(s[0].registFee);
      usd = 10;
    } else if (widget.type == "program_fee_1") {
      amount = 2000000;
      usd = 140;
    } else if (widget.type == "program_fee_2") {
      amount = 3500000;
      usd = 240;
    }

    setState(() {
      paymentAmountIDR = amount;
      paymentAmountUSD = usd;
    });
  }

  buildTextPaymentInfo() {
    return RichText(
      softWrap: true,
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(color: Colors.black),
        children: <TextSpan>[
          TextSpan(
            text: "Payment fee is transferred to:\n",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: "Bank Central Asia(BCA)\n",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "Account Holder: ",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: "Meldi Latifah Saraswati\n",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "Account No.: ",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: "0374505145\n",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "OR\n",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "PayPal\n",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text:
                "paypal.me/istanbulyouthsummit\nistanbulyouthsummit@gmail.com\n",
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  buildPay() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        buildTextPaymentInfo(),
        buildPaymentDateField(),
        buildAccountNameField(),
        buildSourceNameField(),
        buildAmountField(),
        buildProofField(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        GestureDetector(
          onTap: () {
            checkForms();
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
    );
  }

  checkForms() {
    if (accountNameController.text.trim().isNotEmpty &&
        paymentDateController.text.trim().isNotEmpty &&
        sourceNameController.text.trim().isNotEmpty &&
        amountController.text.trim().isNotEmpty &&
        imageFile != null) {
      if (sourceNameController.text.trim().toLowerCase() == "paypal") {
        if (double.parse(amountController.text) != paymentAmountUSD) {
          Fluttertoast.showToast(
              msg: "Payment amount is not correct!",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1);
        } else {
          sendPayment();
        }
      } else {
        if (double.parse(amountController.text) != paymentAmountIDR) {
          Fluttertoast.showToast(
              msg: "Payment amount is not correct!",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1);
        } else {
          sendPayment();
        }
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please complete the input fields first!",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  sendPayment() async {
    Dialogs.showLoadingDialog(context, _key);
    //Navigator.of(context).pop();

    Map<String, dynamic> data = {
      'id_participant': currentUser.id,
      'id_payment_type': widget.paymentTypeId.toString(),
      'account_name': accountNameController.text.trim(),
      'bank_name': sourceNameController.text.trim(),
      'amount': amountController.text.trim(),
      'payment_date': paymentDateController.text.trim(),
    };

    try {
      await Payment.makePayment(data, imageFile);

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();

      Fluttertoast.showToast(
          msg: "Payment has been made. Pull down to refresh page.",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1);
    } on Exception catch (e) {
      print(e);
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "An error occured! Please try again later.",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1);
    }
  }

  Padding buildAccountNameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        style: TextStyle(fontFamily: fontName),
        controller: accountNameController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Account Name",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Input account name",
        ),
      ),
    );
  }

  Padding buildAmountField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        children: [
          TextFormField(
            style: TextStyle(fontFamily: fontName),
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintStyle: TextStyle(fontFamily: fontName),
              errorStyle: TextStyle(fontFamily: fontName),
              border: OutlineInputBorder(),
              labelText: "Amount",
              labelStyle: TextStyle(fontFamily: fontName),
              hintText: "Input payment amount",
            ),
          ),
          SizedBox(height: 5),
          RichText(
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
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: "payment amount must be exactly " +
                      NumberFormat.simpleCurrency(
                              locale: 'eu', decimalDigits: 0, name: '')
                          .format(paymentAmountIDR) +
                      "IDR" +
                      " / " +
                      NumberFormat.simpleCurrency(
                              locale: 'eu', decimalDigits: 0, name: '')
                          .format(paymentAmountUSD) +
                      "USD",
                  style: TextStyle(
                    fontFamily: fontName,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding buildSourceNameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        children: [
          TextFormField(
            style: TextStyle(fontFamily: fontName),
            controller: sourceNameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              hintStyle: TextStyle(fontFamily: fontName),
              errorStyle: TextStyle(fontFamily: fontName),
              border: OutlineInputBorder(),
              labelText: "Source/Bank Name",
              labelStyle: TextStyle(fontFamily: fontName),
              hintText: "Input payment source/bank name",
            ),
          ),
          SizedBox(height: 5),
          RichText(
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
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text:
                      'payment source could be from bank accounts, PayPal, or digital wallets (OVO, DANA, GoPay, etc.)',
                  style: TextStyle(
                    fontFamily: fontName,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding buildPaymentDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        readOnly: true,
        controller: paymentDateController,
        onTap: () async {
          var date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now());

          setState(() {
            paymentDateController.text = DateFormat('yyyy-MM-dd').format(date);
          });
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(fontFamily: fontName),
          errorStyle: TextStyle(fontFamily: fontName),
          border: OutlineInputBorder(),
          labelText: "Payment Date",
          labelStyle: TextStyle(fontFamily: fontName),
          hintText: "Choose payment date",
        ),
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

  Container buildProofField() {
    return Container(
      child: Column(
        children: [
          imageFile == null
              ? Container()
              : Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                        image: FileImage(imageFile), fit: BoxFit.cover),
                  ),
                ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              getImage();
            },
            child: Container(
              height: 40.0,
              width: MediaQuery.of(context).size.width * 0.55,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Center(
                child: Text(
                  "Choose Payment Proof File",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "Payment",
          style: appBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: buildPay(),
    );
  }
}
