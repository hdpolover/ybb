import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ybb/widgets/default_appbar.dart';

class PortalTimeline extends StatefulWidget {
  @override
  _PortalTimelineState createState() => _PortalTimelineState();
}

class _PortalTimelineState extends State<PortalTimeline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          defaultAppBar(context, titleText: "Timeline", removeBackButton: true),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TimelineTile(
              alignment: TimelineAlign.start,
              indicatorStyle: IndicatorStyle(
                width: 30,
                padding: EdgeInsets.only(left: 20, right: 20),
                iconStyle: IconStyle(
                  iconData: Icons.check,
                  color: Colors.white,
                ),
                color: Colors.blue,
              ),
              beforeLineStyle: LineStyle(color: Colors.blue),
              afterLineStyle: LineStyle(color: Colors.blue),
              endChild: Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                ),
                //color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "August 20 - September 20, 2020",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Registration",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TimelineTile(
              alignment: TimelineAlign.start,
              indicatorStyle: IndicatorStyle(
                width: 30,
                padding: EdgeInsets.only(left: 20, right: 20),
                iconStyle: IconStyle(
                  iconData: Icons.check,
                  color: Colors.white,
                ),
                color: Colors.blue,
              ),
              beforeLineStyle: LineStyle(color: Colors.blue),
              afterLineStyle: LineStyle(color: Colors.blue),
              endChild: Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                ),
                //color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "October 20, 2020",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Selected Participant Announcement",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TimelineTile(
              alignment: TimelineAlign.start,
              indicatorStyle: IndicatorStyle(
                width: 30,
                padding: EdgeInsets.only(left: 20, right: 20),
                color: Colors.grey,
              ),
              beforeLineStyle: LineStyle(color: Colors.grey),
              afterLineStyle: LineStyle(color: Colors.grey),
              endChild: Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                ),
                //color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "November 14 - 15, 2020",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Fully Funded Interview",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TimelineTile(
              alignment: TimelineAlign.start,
              indicatorStyle: IndicatorStyle(
                width: 30,
                padding: EdgeInsets.only(left: 20, right: 20),
                color: Colors.grey,
              ),
              beforeLineStyle: LineStyle(color: Colors.grey),
              afterLineStyle: LineStyle(color: Colors.grey),
              endChild: Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                ),
                //color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "November 15, 2020",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Fully Funded Announcement",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TimelineTile(
              alignment: TimelineAlign.start,
              indicatorStyle: IndicatorStyle(
                width: 30,
                padding: EdgeInsets.only(left: 20, right: 20),
                color: Colors.grey,
              ),
              beforeLineStyle: LineStyle(color: Colors.grey),
              afterLineStyle: LineStyle(color: Colors.grey),
              endChild: Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                ),
                //color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "November 15, 2020",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Fully Funded Announcement",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TimelineTile(
              alignment: TimelineAlign.start,
              indicatorStyle: IndicatorStyle(
                width: 30,
                padding: EdgeInsets.only(left: 20, right: 20),
                color: Colors.grey,
              ),
              beforeLineStyle: LineStyle(color: Colors.grey),
              afterLineStyle: LineStyle(color: Colors.grey),
              endChild: Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                ),
                //color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "February 4 - 7, 2020",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Istanbul Youth Summit 2020",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
