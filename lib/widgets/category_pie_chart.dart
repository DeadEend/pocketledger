import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/expense_category.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key, required this.entries});

  final List<MapEntry<ExpenseCategory, double>> entries;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 36,
        startDegreeOffset: -90,
        borderData: FlBorderData(show: false),
        pieTouchData: PieTouchData(enabled: false),
        sections: [
          for (final entry in entries)
            PieChartSectionData(
              value: entry.value,
              color: entry.key.color,
              radius: 22,
              showTitle: false,
            ),
        ],
      ),
    );
  }
}
