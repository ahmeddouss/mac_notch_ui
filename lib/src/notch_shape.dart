import 'package:flutter/widgets.dart';

class NotchClipper extends CustomClipper<Path> {
  final double bottomCornerRadius;

  NotchClipper({required this.bottomCornerRadius});

  double get topCornerRadius =>
      bottomCornerRadius > 15 ? bottomCornerRadius - 5 : 5;

  @override
  Path getClip(Size size) {
    final path = Path();
    // Using rect for easier read matching swift code
    final rect = Offset.zero & size;

    // Start from the top left corner
    path.moveTo(rect.left, rect.top);

    // Top left inner curve
    path.quadraticBezierTo(
      rect.left + topCornerRadius, rect.top, // Control
      rect.left + topCornerRadius, rect.top + topCornerRadius, // End
    );

    // Left vertical line
    path.lineTo(
        rect.left + topCornerRadius, rect.bottom - bottomCornerRadius);

    // Bottom left corner
    path.quadraticBezierTo(
      rect.left + topCornerRadius, rect.bottom, // Control
      rect.left + topCornerRadius + bottomCornerRadius, rect.bottom, // End
    );

    // Bottom horizontal line
    path.lineTo(
        rect.right - topCornerRadius - bottomCornerRadius, rect.bottom);

    // Bottom right corner
    path.quadraticBezierTo(
      rect.right - topCornerRadius, rect.bottom, // Control
      rect.right - topCornerRadius, rect.bottom - bottomCornerRadius, // End
    );

    // Right vertical line
    path.lineTo(rect.right - topCornerRadius, rect.top + topCornerRadius);

    // Top right inner curve
    path.quadraticBezierTo(
      rect.right - topCornerRadius, rect.top, // Control
      rect.right, rect.top, // End
    );

    // Closing the path
    path.lineTo(rect.left, rect.top);
    path.close();

    return path;
    
  }

  @override
  bool shouldReclip(NotchClipper oldClipper) {
    return oldClipper.bottomCornerRadius != bottomCornerRadius;
  }
}
