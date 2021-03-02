import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileHeaderShimmer extends StatefulWidget {
  ProfileHeaderShimmer({Key key}) : super(key: key);

  @override
  _ProfileHeaderShimmerState createState() => _ProfileHeaderShimmerState();
}

class _ProfileHeaderShimmerState extends State<ProfileHeaderShimmer> {
  @override
  Widget build(BuildContext context) {
    var containerWidth = MediaQuery.of(context).size.width;
    var containerHeight = MediaQuery.of(context).size.height;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.white,
      child: Container(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 40,
            ),
            SizedBox(width: containerWidth * 0.07),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.grey,
                  width: containerWidth * 0.5,
                  height: containerHeight * 0.02,
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.grey,
                  width: containerWidth * 0.3,
                  height: containerHeight * 0.01,
                ),
                SizedBox(height: containerHeight * 0.04),
                Container(
                  color: Colors.grey,
                  width: containerWidth * 0.4,
                  height: containerHeight * 0.01,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
