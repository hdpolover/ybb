import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserSuggestionShimmer extends StatefulWidget {
  UserSuggestionShimmer({Key key}) : super(key: key);

  @override
  _UserSuggestionShimmerState createState() => _UserSuggestionShimmerState();
}

class _UserSuggestionShimmerState extends State<UserSuggestionShimmer> {
  buildLayout(containerWidth, containerHeight) {
    return Container(
      margin: EdgeInsets.only(right: 6),
      height: containerHeight * 0.2,
      width: containerWidth * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 30,
          ),
          SizedBox(height: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Colors.grey,
                width: containerWidth * 0.25,
                height: containerHeight * 0.02,
              ),
              SizedBox(height: 40),
              Container(
                color: Colors.grey,
                width: containerWidth * 0.2,
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
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              buildLayout(containerWidth, containerHeight),
              buildLayout(containerWidth, containerHeight),
              buildLayout(containerWidth, containerHeight),
            ],
          )),
    );
  }
}
