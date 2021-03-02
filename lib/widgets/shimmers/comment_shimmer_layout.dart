import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommentShimmer extends StatefulWidget {
  CommentShimmer({Key key}) : super(key: key);

  @override
  _CommentShimmerState createState() => _CommentShimmerState();
}

class _CommentShimmerState extends State<CommentShimmer> {
  buildShimmer(containerWidth, containerHeight) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
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
                width: containerWidth * 0.7,
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
            buildShimmer(containerWidth, containerHeight),
            buildShimmer(containerWidth, containerHeight),
            buildShimmer(containerWidth, containerHeight),
            buildShimmer(containerWidth, containerHeight),
          ],
        )),
      ),
    );
  }
}
