import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SummitShimmer extends StatefulWidget {
  SummitShimmer({Key key}) : super(key: key);

  @override
  _SummitShimmerState createState() => _SummitShimmerState();
}

class _SummitShimmerState extends State<SummitShimmer> {
  buildShimmer(containerWidth, containerHeight) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.grey,
                width: containerWidth * 0.435,
                height: containerHeight * 0.1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var containerWidth = MediaQuery.of(context).size.width;
    var containerHeight = MediaQuery.of(context).size.height;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildShimmer(containerWidth, containerHeight),
                buildShimmer(containerWidth, containerHeight),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildShimmer(containerWidth, containerHeight),
                buildShimmer(containerWidth, containerHeight),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
