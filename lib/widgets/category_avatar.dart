import 'package:flutter/material.dart';

import '../models/expense_category.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.category, this.size = 40});

  final ExpenseCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.tint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(category.icon, size: size * 0.5, color: category.color),
    );
  }
}
