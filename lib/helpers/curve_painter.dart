import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.blue;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
        size.width / 2, size.height / 2, size.width, size.height * 0.47);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    // path.moveTo(0, size.height * 0.3);
    // path.quadraticBezierTo(
    //     size.width / 3, size.height / 3, size.width, size.height * 0.3);
    // path.lineTo(size.width, 0);
    // path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
