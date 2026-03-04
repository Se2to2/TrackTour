import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const FieldLabel({
    super.key,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? AppColors.labelColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}
