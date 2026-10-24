import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Simple app mark: a rounded square with the rupee sign.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Text(
        '₹',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
