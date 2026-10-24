import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

AppBar buildAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
}) {
  return AppBar(
    title: Text(title),
    actions: actions,
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.background,
    surfaceTintColor: Colors.transparent,
    foregroundColor: AppColors.text,
    titleTextStyle: Theme.of(context).textTheme.titleLarge,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    ),
  );
}
