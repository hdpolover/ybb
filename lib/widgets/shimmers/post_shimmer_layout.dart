import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostShimmer extends StatefulWidget {
  @override
  _PostShimmerState createState() => _PostShimmerState();
}

class _PostShimmerState extends State<PostShimmer> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            buildLayout(),
            buildLayout(),
          ],
        ),
      ),
    );
  }

  buildLayout() {
    var containerWidth = MediaQuery.of(context).size.width;
    var containerHeight = MediaQuery.of(context).size.height;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.grey,
                width: containerWidth,
                height: containerHeight * 0.01,
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
              SizedBox(height: 10),
              Container(
                color: Colors.grey,
                width: containerWidth,
                height: containerHeight * 0.3,
              ),
            ],
          ),
          SizedBox(height: containerHeight * 0.02),
          Row(
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
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.grey,
                width: containerWidth,
                height: containerHeight * 0.01,
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
            ],
          ),
        ],
      ),
    );
  }
}
