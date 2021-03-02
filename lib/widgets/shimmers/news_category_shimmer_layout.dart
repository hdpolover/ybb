import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NewsCategoryShimmer extends StatefulWidget {
  NewsCategoryShimmer({Key key}) : super(key: key);

  @override
  _NewsCategoryShimmerState createState() => _NewsCategoryShimmerState();
}

class _NewsCategoryShimmerState extends State<NewsCategoryShimmer> {
  shimmerLayout(containerWidth, containerHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.grey,
          width: containerWidth,
          height: containerHeight * 0.2,
        ),
        SizedBox(height: 10),
        Container(
          color: Colors.grey,
          width: containerWidth,
          height: containerHeight * 0.02,
        ),
        SizedBox(height: 10),
        Container(
          color: Colors.grey,
          width: containerWidth * 0.8,
          height: containerHeight * 0.01,
        ),
        SizedBox(height: 10),
        Container(
          color: Colors.grey,
          width: containerWidth,
          height: containerHeight * 0.01,
        ),
        SizedBox(height: 15),
      ],
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
              shimmerLayout(containerWidth, containerHeight),
              shimmerLayout(containerWidth, containerHeight),
              shimmerLayout(containerWidth, containerHeight),
            ],
          ),
        ),
      ),
    );
  }
}
