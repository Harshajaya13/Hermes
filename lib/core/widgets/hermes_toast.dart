import 'package:flutter/material.dart';
import '../theme/hermes_theme.dart';

class HermesToast {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: HermesTypography.bodySmall.copyWith(
            color: isError ? HermesColors.error : HermesColors.textPrimary,
          ),
        ),
        backgroundColor: HermesColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HermesRadius.md),
          side: BorderSide(
            color: HermesColors.border.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        elevation: 0,
        margin: const EdgeInsets.all(HermesSpacing.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: HermesSpacing.lg,
          vertical: HermesSpacing.md,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
