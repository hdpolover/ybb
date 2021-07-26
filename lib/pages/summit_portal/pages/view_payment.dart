import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ybb/helpers/api/payment.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/widgets/full_photo.dart';

class ViewPayment extends StatefulWidget {
  final Payment payment;

  ViewPayment({@required this.payment});
  @override
  _ViewPaymentState createState() => _ViewPaymentState(p: this.payment);
}

class _ViewPaymentState extends State<ViewPayment> {
  Payment p;

  _ViewPaymentState({this.p});

  buildViewPayment() {
    String text =
        NumberFormat.simpleCurrency(locale: 'eu', decimalDigits: 0, name: '')
                .format(p.amount) +
            'IDR';

    String status = "";
    switch (p.paymentStatus) {
      case 0:
        status = "Pending";
        break;
      case 1:
        status = "Success";
        break;
      case 2:
        status = "Invalid";
        break;
    }

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(p.paymentDate);

    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        buildHorizontalField("Payment Date", formatted),
        buildHorizontalField("Account Name", p.accountName),
        buildHorizontalField("Bank Name", p.bankName),
        buildHorizontalField("Amount", text),
        buildHorizontalField("Paid for", p.paymentType),
        buildHorizontalField("Status", status),
        SizedBox(height: 20),
        buildPaymentProof(),
      ],
    );
  }

  buildPaymentProof() {
    String url = baseUrl +
        "/assets/img/payments/" +
        p.paymentTypeId.toString() +
        "/" +
        p.paymentProof;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullPhoto(url: url),
          ),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  buildHorizontalField(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Text(
            content,
            textAlign: TextAlign.justify,
            softWrap: true,
            style: contentStyle,
          ),
        ],
      ),
    );
  }

  TextStyle titleStyle = new TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  TextStyle contentStyle = new TextStyle(
    fontFamily: fontName,
    letterSpacing: 0.7,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "Payment Details",
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
      body: buildViewPayment(),
    );
  }
}
