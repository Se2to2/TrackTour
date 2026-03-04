import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BottomWave extends StatelessWidget {
  final double height;
  final Color? color;
  final double opacity;

  const BottomWave({
    super.key,
    this.height = 80,
    this.color,
    this.opacity = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _BottomWaveClipper(),
        child: Container(
          height: height,
          color: (color ?? AppColors.accentColor).withOpacity(opacity),
        ),
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      0,
      size.width * 0.5,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.2,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
