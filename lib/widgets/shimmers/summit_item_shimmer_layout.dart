import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SummitItemShimmer extends StatefulWidget {
  @override
  _SummitItemShimmerState createState() => _SummitItemShimmerState();
}

class _SummitItemShimmerState extends State<SummitItemShimmer> {
  buildShimmer() {
    var containerWidth = MediaQuery.of(context).size.width;
    var containerHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.grey,
                width: containerWidth * 0.88,
                height: containerHeight * 0.1,
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.grey,
                width: containerWidth * 0.88,
                height: containerHeight * 0.015,
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.grey,
                width: containerWidth * 0.7,
                height: containerHeight * 0.015,
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.grey,
                width: containerWidth * 0.88,
                height: containerHeight * 0.015,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.white,
      child: Container(
          child: Column(
        children: [
          buildShimmer(),
          buildShimmer(),
          buildShimmer(),
          buildShimmer(),
        ],
      )),
    );
  }
}
