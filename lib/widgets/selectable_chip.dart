import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Chip used for category pickers and filters.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color = AppColors.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      backgroundColor: AppColors.surface,
      selectedColor: color.withAlpha(36),
      side: BorderSide(color: selected ? color : AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        color: AppColors.text,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }
}
