import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostHeaderShimmer extends StatefulWidget {
  @override
  _PostHeaderShimmerState createState() => _PostHeaderShimmerState();
}

class _PostHeaderShimmerState extends State<PostHeaderShimmer> {
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
              radius: 25,
            ),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.grey,
                  width: containerWidth * 0.6,
                  height: containerHeight * 0.02,
                ),
                SizedBox(height: 10),
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
