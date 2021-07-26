import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ybb/helpers/api/summit_timeline.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/summit_item_shimmer_layout.dart';

class PortalTimeline extends StatefulWidget {
  @override
  _PortalTimelineState createState() => _PortalTimelineState();
}

class _PortalTimelineState extends State<PortalTimeline>
    with AutomaticKeepAliveClientMixin<PortalTimeline> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    buildTimeline() {
      return FutureBuilder(
        future: SummitTimeline.getTimelines(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SummitItemShimmer();
          }

          List<SummitTimeline> st = snapshot.data;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            itemCount: st.length,
            itemBuilder: (context, index) {
              DateTime current = new DateTime.now();
              bool isUpcoming = st[index].startTimeline.isAfter(current);

              return TimelineTile(
                alignment: TimelineAlign.start,
                indicatorStyle: isUpcoming
                    ? IndicatorStyle(
                        width: 30,
                        padding: EdgeInsets.only(left: 10, right: 30),
                        color: Colors.grey,
                      )
                    : IndicatorStyle(
                        width: 30,
                        padding: EdgeInsets.only(left: 10, right: 30),
                        iconStyle: IconStyle(
                          iconData: Icons.check,
                          color: Colors.white,
                        ),
                        color: Colors.blue,
                      ),
                beforeLineStyle:
                    LineStyle(color: isUpcoming ? Colors.grey : Colors.blue),
                afterLineStyle:
                    LineStyle(color: isUpcoming ? Colors.grey : Colors.blue),
                endChild: Container(
                  constraints: const BoxConstraints(
                    minHeight: 150,
                  ),
                  //color: Colors.blue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        st[index].timeline,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isUpcoming ? Colors.grey : Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        st[index].description,
                        style: TextStyle(
                          fontSize: 17,
                          color: isUpcoming ? Colors.grey : Colors.black,
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        st[index].endTimeline.isBefore(current)
                            ? "Ended " +
                                st[index]
                                    .endTimeline
                                    .difference(current)
                                    .inDays
                                    .toString()
                                    .substring(1) +
                                " days ago"
                            : st[index].startTimeline.isAfter(current)
                                ? "Starts in " +
                                    st[index]
                                        .endTimeline
                                        .difference(current)
                                        .inDays
                                        .toString() +
                                    " days"
                                : "Ends in " +
                                    st[index]
                                        .endTimeline
                                        .difference(current)
                                        .inDays
                                        .toString() +
                                    " days",
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: defaultAppBar(context,
          titleText: "Summit Timeline", removeBackButton: true),
      body: buildTimeline(),
    );
  }

  bool get wantKeepAlive => true;
}
