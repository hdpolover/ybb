import 'package:flutter/material.dart';
import 'package:ybb/widgets/default_appbar.dart';

class PortalPayment extends StatefulWidget {
  @override
  _PortalPaymentState createState() => _PortalPaymentState();
}

class _PortalPaymentState extends State<PortalPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          defaultAppBar(context, titleText: "Payment", removeBackButton: true),
      body: ListView(
        children: [
          PaymentTile(),
          PaymentTile(),
        ],
      ),
    );
  }
}

class PaymentTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Registration Fee",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "125.000 IDR",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 40),
          Text(
            "Due: July 10, 2021",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
