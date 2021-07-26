import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/api/payment.dart';
import 'package:ybb/helpers/api/payment_type.dart';
import 'package:ybb/helpers/api/summit.dart';
import 'package:ybb/helpers/api/summit_participant.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/summit_portal/pages/pay.dart';
import 'package:ybb/pages/summit_portal/pages/view_payment.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/summit_item_shimmer_layout.dart';

class PortalPayment extends StatefulWidget {
  @override
  _PortalPaymentState createState() => _PortalPaymentState();
}

class _PortalPaymentState extends State<PortalPayment>
    with AutomaticKeepAliveClientMixin<PortalPayment> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  List<PaymentType> pt = [];

  Future<Null> refreshSummitHome() async {
    refreshkey.currentState?.show(atTop: true);

    setState(() {
      pt = [];
    });

    await getPaymentTypes();
  }

  getPaymentTypes() {
    return FutureBuilder(
      future: PaymentType.getPaymentTypes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SummitItemShimmer();
        }

        pt = snapshot.data;
        List<PaymentType> p = [];

        DateTime currentDate = new DateTime.now();

        for (int i = 0; i < pt.length; i++) {
          if (!pt[i].startDate.isAfter(currentDate)) {
            p.add(pt[i]);
          }
        }

        pt = p.toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          itemCount: pt.length,
          itemBuilder: (context, index) {
            return PaymentTypeItem(
              content: pt[index],
              context: context,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Summit Payment", removeBackButton: true),
      body: LiquidPullToRefresh(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.blue,
        animSpeedFactor: 2.5,
        backgroundColor: Colors.white,
        showChildOpacityTransition: false,
        key: refreshkey,
        onRefresh: refreshSummitHome,
        child: getPaymentTypes(),
      ),
    );
  }

  bool get wantKeepAlive => true;
}

class PaymentTypeItem extends StatefulWidget {
  final BuildContext context;
  final PaymentType content;

  PaymentTypeItem({
    @required this.content,
    @required this.context,
  });

  @override
  _PaymentTypeItemState createState() => _PaymentTypeItemState(
        pt: this.content,
        ctx: this.context,
      );
}

class _PaymentTypeItemState extends State<PaymentTypeItem> {
  PaymentType pt;
  BuildContext ctx;

  _PaymentTypeItemState({this.pt, this.ctx});

  SummitParticipant sp;

  @override
  void initState() {
    super.initState();
    getSummitParticipant();
  }

  getSummitParticipant() async {
    SummitParticipant p =
        await SummitParticipant.getParticipant(currentUser.id);

    setState(() {
      sp = p;
    });
  }

  buildPaymentAmount() {
    return FutureBuilder(
      future: Summit.getSummitById(pt.summitId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        Summit s = snapshot.data[0];

        double registFee = double.parse(s.registFee);

        String text = "";
        double feeAmount = 0;
        if (pt.type == "regist_fee") {
          feeAmount = registFee;
          text = NumberFormat.simpleCurrency(
                      locale: 'eu', decimalDigits: 0, name: '')
                  .format(feeAmount) +
              'IDR' +
              " / " +
              NumberFormat.simpleCurrency(
                      locale: 'eu', decimalDigits: 0, name: '')
                  .format(10) +
              'USD';
        } else if (pt.type == "program_fee_1") {
          feeAmount = 2000000;
          text = NumberFormat.simpleCurrency(
                      locale: 'eu', decimalDigits: 0, name: '')
                  .format(feeAmount) +
              'IDR' +
              " / " +
              NumberFormat.simpleCurrency(
                      locale: 'eu', decimalDigits: 0, name: '')
                  .format(140) +
              'USD';
        } else if (pt.type == "program_fee_2") {
          feeAmount = 3500000;
          text = NumberFormat.simpleCurrency(
                      locale: 'eu', decimalDigits: 0, name: '')
                  .format(feeAmount) +
              'IDR' +
              " / " +
              NumberFormat.simpleCurrency(
                      locale: 'eu', decimalDigits: 0, name: '')
                  .format(240) +
              'USD';
        }

        return Text(text);
      },
    );
  }

  checkPaymentAvailability(int summitId, SummitParticipant sp) async {
    if (sp.status == 0) {
      return Fluttertoast.showToast(
          msg: "Please complete the registration form first.",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    } else if (sp.status == 1 && pt.paymentTypeId == 2) {
      return Fluttertoast.showToast(
          msg: "Please complete the registration fee first.",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Pay(
            summitId: summitId,
            type: pt.type,
            paymentTypeId: pt.paymentTypeId,
          ),
        ),
      );
    }
  }

  buildDueDate() {
    DateTime current = new DateTime.now();

    bool isDue = pt.endDate.isBefore(current);
    return isDue
        ? Text(
            "Payment due",
            style: TextStyle(
              fontSize: 15,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          )
        : pt.startDate.isAfter(current)
            ? Text(
                "Starts in " +
                    pt.endDate.difference(current).inDays.toString() +
                    " days",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              )
            : Text(
                "Due in " +
                    pt.endDate.difference(current).inDays.toString() +
                    " days",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red,
                ),
              );
  }

  buildStatusChip(int summitId) {
    DateTime current = new DateTime.now();
    bool isAvailable = pt.startDate.isAtSameMomentAs(current) ||
        pt.startDate.isBefore(current);

    bool isDue = pt.endDate.isBefore(current);

    return FutureBuilder(
      future: Payment.getPaymentStatus(currentUser.id, pt.paymentTypeId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: isDue
                      ? () {}
                      : isAvailable
                          ? () {
                              checkPaymentAvailability(summitId, sp);
                            }
                          : null,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDue
                          ? Colors.grey
                          : isAvailable
                              ? Colors.blue
                              : Colors.grey,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        isDue
                            ? "Not Available"
                            : isAvailable
                                ? "Pay"
                                : "Not Available",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        Payment p = snapshot.data[0];

        String chipText = "";
        Color chipColor = Colors.blue;
        switch (p.paymentStatus) {
          case 0:
            chipText = "Pending";
            chipColor = Colors.yellow;
            break;
          case 1:
            chipText = "Success";
            chipColor = Colors.green;
            break;
          case 2:
            chipText = "Invalid";
            chipColor = Colors.red;
            break;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(
              elevation: 0,
              padding: EdgeInsets.all(10),
              backgroundColor: chipColor, //CircleAvatar
              label: Text(
                chipText,
                style: TextStyle(
                  fontFamily: "SFProText",
                  letterSpacing: 0.5,
                  color: Colors.black,
                ),
              ), //Text
            ),
            SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewPayment(
                        payment: p,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Center(
                    child: Text(
                      "View Details",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pt.description,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          buildPaymentAmount(),
          SizedBox(height: 20),
          buildDueDate(),
          SizedBox(height: 20),
          buildStatusChip(pt.summitId),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
