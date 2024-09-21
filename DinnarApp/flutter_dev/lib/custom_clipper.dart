import 'package:flutter/material.dart';

class CustomClipperWidget extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from the top-left corner
    path.lineTo(0, size.height * 0.7);

   
    final controlPoint1 = Offset(
        size.width * 0.08, size.height + 100);
    final controlPoint2 = Offset(size.width * 0.999,
        size.height * 0.9 + 80); // Increase the y-coordinate
    final endPoint = Offset(size.width, size.height * 0.75);

    // Add a cubic Bézier curve for the slight curve at the bottom
    path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
        controlPoint2.dy, endPoint.dx, endPoint.dy);

    // Draw line to bottom-right corner
    path.lineTo(size.width, 0);

    // Draw line to bottom-left corner
    path.lineTo(0, 0);

    // Close the path to form a closed shape
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // Returning true here will ensure the clipper will be updated if needed
    return true;
  }
}
