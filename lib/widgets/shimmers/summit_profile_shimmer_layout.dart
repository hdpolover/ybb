import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SummitProfileShimmer extends StatefulWidget {
  @override
  _SummitProfileShimmerState createState() => _SummitProfileShimmerState();
}

class _SummitProfileShimmerState extends State<SummitProfileShimmer> {
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

  buildHead() {
    var containerWidth = MediaQuery.of(context).size.width;
    var containerHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.grey,
                width: containerWidth * 0.5,
                height: containerHeight * 0.3,
              ),
              SizedBox(height: 20),
              Container(
                color: Colors.grey,
                width: containerWidth * 0.6,
                height: containerHeight * 0.03,
              ),
              SizedBox(height: 20),
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
          buildHead(),
          buildShimmer(),
          buildShimmer(),
        ],
      )),
    );
  }
}
