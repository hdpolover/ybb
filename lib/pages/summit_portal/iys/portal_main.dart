import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ybb/pages/summit_portal/iys/portal_home.dart';
import 'package:ybb/pages/summit_portal/iys/portal_payment.dart';
import 'package:ybb/pages/summit_portal/iys/portal_profile.dart';
import 'package:ybb/pages/summit_portal/iys/portal_timeline.dart';

class PortalMain extends StatefulWidget {
  @override
  _PortalMainState createState() => _PortalMainState();
}

class _PortalMainState extends State<PortalMain> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  GlobalKey _bottomNavigationKey = GlobalKey();
  bool portalHomeSelected = true;
  bool portalTimelineSelected = false;
  bool portalPaymentSelected = false;
  bool portalProfileSelected = false;

  Scaffold buildPortalMain() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          PortalHome(),
          PortalTimeline(),
          PortalPayment(),
          PortalProfile(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        onTap: (index) {
          onTap(index);
          setState(
            () {
              switch (index) {
                case 0:
                  portalHomeSelected = true;
                  portalTimelineSelected = false;
                  portalPaymentSelected = false;
                  portalProfileSelected = false;
                  break;
                case 1:
                  portalHomeSelected = false;
                  portalTimelineSelected = true;
                  portalPaymentSelected = false;
                  portalProfileSelected = false;
                  break;
                case 2:
                  portalHomeSelected = false;
                  portalTimelineSelected = false;
                  portalPaymentSelected = true;
                  portalProfileSelected = false;
                  break;
                case 3:
                  portalHomeSelected = false;
                  portalTimelineSelected = false;
                  portalPaymentSelected = false;
                  portalProfileSelected = true;
                  break;
                default:
                  portalHomeSelected = true;
                  portalTimelineSelected = false;
                  portalPaymentSelected = false;
                  portalProfileSelected = false;
                  break;
              }
            },
          );
        },
        height: MediaQuery.of(context).size.height * 0.06,
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        key: _bottomNavigationKey,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 400),
        letIndexChange: (index) => true,
        items: [
          Icon(
            Icons.dashboard_outlined,
            size: 25,
            color: portalHomeSelected
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          Icon(
            Icons.timeline_rounded,
            size: 25,
            color: portalTimelineSelected
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          Icon(
            Icons.payment,
            size: 25,
            color: portalPaymentSelected
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          Icon(
            //Icons.confirmation_num,
            Icons.person,
            size: 25,
            color: portalProfileSelected
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildPortalMain();
  }
}
