import 'package:flutter/material.dart';

enum ExpenseCategory {
  food('Food', Icons.restaurant_outlined, Color(0xFFC77D4E)),
  travel('Travel', Icons.directions_bus_outlined, Color(0xFF4C7EA6)),
  books('Books', Icons.menu_book_outlined, Color(0xFF7B6BA8)),
  rent('Rent', Icons.home_outlined, Color(0xFF8B7355)),
  entertainment('Entertainment', Icons.movie_outlined, Color(0xFFB5607F)),
  bills('Bills', Icons.receipt_long_outlined, Color(0xFFC2A04A)),
  other('Other', Icons.category_outlined, Color(0xFF8A8F98));

  const ExpenseCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Light version of the colour, used behind icons and on selected chips.
  Color get tint => color.withAlpha(36);

  /// Unknown or missing names fall back to [other].
  static ExpenseCategory fromLabel(String label) {
    for (final category in values) {
      if (category.label == label) return category;
    }
    return other;
  }
}
