import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1F2328);
  static const Color textMuted = Color(0xFF6B6F76);
  static const Color border = Color(0xFFE6E0D6);
  static const Color accent = Color(0xFF1F6F5C);
  static const Color accentSoft = Color(0xFFE3EFEA);
  static const Color accentDisabled = Color(0xFF8FB3A8);
  static const Color success = Color(0xFF2E7D4F);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningSoft = Color(0xFFF6EAD3);
  static const Color danger = Color(0xFFB3402F);
  static const Color dangerSoft = Color(0xFFF7E4E0);
}

/// 8px spacing scale (with a 4px half step).
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  const AppRadius._();

  static const double card = 12;
  static const double field = 8;
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: Colors.white,
    primaryContainer: AppColors.accentSoft,
    onPrimaryContainer: AppColors.accent,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.accentSoft,
    onSecondaryContainer: AppColors.accent,
    surface: AppColors.background,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    error: AppColors.danger,
    onError: Colors.white,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.background,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surface,
    surfaceContainerHighest: Color(0xFFF1ECE3),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
  );

  final inter = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  );

  final textTheme = inter.copyWith(
    headlineMedium:
        inter.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall:
        inter.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
    titleLarge:
        inter.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium:
        inter.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall:
        inter.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: inter.bodyLarge?.copyWith(fontSize: 16),
    bodyMedium: inter.bodyMedium?.copyWith(fontSize: 14),
    bodySmall:
        inter.bodySmall?.copyWith(fontSize: 12, color: AppColors.textMuted),
    labelLarge:
        inter.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
  );

  return base.copyWith(textTheme: textTheme);
}

/// Shared look for every text field.
InputDecoration appInputDecoration({
  String? label,
  String? hint,
  String? helper,
  String? prefixText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    prefixText: prefixText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 14,
    ),
    hintStyle: const TextStyle(color: AppColors.textMuted),
    border: border(AppColors.border),
    enabledBorder: border(AppColors.border),
    disabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.accent, 1.5),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.5),
  );
}

ButtonStyle outlinedButtonStyle({Color color = AppColors.accent}) {
  return OutlinedButton.styleFrom(
    foregroundColor: color,
    minimumSize: const Size(0, 44),
    side: const BorderSide(color: AppColors.border),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
    ),
  );
}
