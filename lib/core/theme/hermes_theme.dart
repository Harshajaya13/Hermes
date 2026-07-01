import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Hermes Design System
/// ─────────────────────────────────────────────────────────────────────────────
/// Derived from the Hermes Codex — Visual Language & Design Philosophy.
///
/// "The interface should disappear so the user's thinking becomes the focus."
/// "Hermes should feel like a premium notebook crafted by someone who deeply
///  respects your thoughts."
///
/// Visual DNA: OLED Black · Calm · Quiet · Personal · Trustworthy · Timeless
/// ─────────────────────────────────────────────────────────────────────────────

class HermesColors {
  HermesColors._();

  // ── Core Surfaces ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFF000000); // Pure OLED black
  static const Color surface = Color(0xFF0A0A0A); // Barely-there elevation
  static const Color surfaceElevated = Color(0xFF141414); // Cards / Sheets
  static const Color surfaceOverlay = Color(0xFF1A1A1A); // Dialogs / Modals

  // ── Text Hierarchy ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE6E6E6); // Headings
  static const Color textSecondary = Color(0xFFC8C8C8); // Body text
  static const Color textTertiary = Color(0xFF9A9A9A); // Metadata
  static const Color textHint = Color(0xFF7A7A7A); // Hints / placeholders
  static const Color textDisabled = Color(0xFF3A3A3A); // Truly inactive

  // ── Accent — Muted, Intentional ────────────────────────────────────────────
  // No bright reds. No harsh blues. Muted, warm, calm.
  static const Color accent = Color(0xFF7C9EBC); // Gentle slate blue
  static const Color accentWarm = Color(0xFFBFA07A); // Warm amber whisper
  static const Color accentSoft = Color(0xFF8BAA8E); // Soft sage green
  static const Color accentMuted = Color(0xFFA08EB4); // Quiet lavender

  // ── Semantic Colors ────────────────────────────────────────────────────────
  static const Color evolutioGlow = Color(0xFF8BAA8E); // Growth moments
  static const Color veritasColor = Color(0xFFBFA07A); // Truth / honesty
  static const Color reflectionColor = Color(0xFF7C9EBC); // Thinking moments
  static const Color archiveColor = Color(0xFF6B6B6B); // Safety / storage
  static const Color error = Color(0xFFCF6679); // Destructive / irreversible

  // ── Borders & Dividers ─────────────────────────────────────────────────────
  static const Color border = Color(0xFF1E1E1E);
  static const Color divider = Color(0xFF1A1A1A);

  // ── Contribution Graph (like GitHub, but for growth) ───────────────────────
  static const Color commitEmpty = Color(0xFF161616);
  static const Color commitLight = Color(0xFF2D4A2D);
  static const Color commitMedium = Color(0xFF3D6B3D);
  static const Color commitStrong = Color(0xFF5A9A5A);
  static const Color commitFull = Color(0xFF7CC47C);
}

class HermesSpacing {
  HermesSpacing._();

  /// Codex Law: "Every element must have room to breathe."
  /// Codex Law: "Empty space is an active design element, not leftover space."

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ── Screen Edge Padding ────────────────────────────────────────────────────
  static const double screenHorizontal = 24.0;
  static const double screenTop = 16.0;

  // ── Section Spacing ────────────────────────────────────────────────────────
  static const double sectionGap = 36.0; // Between major sections
  static const double itemGap = 12.0; // Between list items
  static const double cardPadding = 20.0; // Inside cards
}

class HermesRadius {
  HermesRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double pill = 100.0;
}

class HermesDurations {
  HermesDurations._();

  /// Codex: "Motion should feel natural. Never draw attention to itself."
  /// Codex: "Speed over spectacle."

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration entrance = Duration(milliseconds: 600);
}

class HermesTypography {
  HermesTypography._();

  /// Codex Typography Hierarchy:
  /// Screen Title → Section Title → Block Title → Item Title → Body → Metadata

  static TextStyle get _base => GoogleFonts.inter();

  // ── Screen Title ───────────────────────────────────────────────────────────
  static TextStyle get screenTitle => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: HermesColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  // ── Section Title ──────────────────────────────────────────────────────────
  static TextStyle get sectionTitle => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: HermesColors.textTertiary,
        letterSpacing: 1.5,
        height: 1.4,
      );

  // ── Block Title ────────────────────────────────────────────────────────────
  static TextStyle get blockTitle => _base.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: HermesColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.3,
      );

  // ── Item Title ─────────────────────────────────────────────────────────────
  static TextStyle get itemTitle => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: HermesColors.textPrimary,
        letterSpacing: -0.1,
        height: 1.4,
      );

  // ── Body ───────────────────────────────────────────────────────────────────
  static TextStyle get body => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: HermesColors.textSecondary,
        height: 1.6,
      );

  // ── Body Small ─────────────────────────────────────────────────────────────
  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: HermesColors.textSecondary,
        height: 1.5,
      );

  // ── Metadata ───────────────────────────────────────────────────────────────
  static TextStyle get metadata => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: HermesColors.textTertiary,
        letterSpacing: 0.2,
        height: 1.4,
      );

  // ── Quote / Reflection ─────────────────────────────────────────────────────
  static TextStyle get reflection => GoogleFonts.libreBaskerville(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: HermesColors.textSecondary,
        fontStyle: FontStyle.italic,
        height: 1.8,
      );

  // ── Evolutio Highlight ─────────────────────────────────────────────────────
  static TextStyle get evolutio => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: HermesColors.evolutioGlow,
        height: 1.5,
      );

  // ── Button ─────────────────────────────────────────────────────────────────
  static TextStyle get button => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: HermesColors.textPrimary,
        letterSpacing: 0.3,
      );

  // ── Tab Label ──────────────────────────────────────────────────────────────
  static TextStyle get tabLabel => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  // ── Large Number / Stat ────────────────────────────────────────────────────
  static TextStyle get stat => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: HermesColors.textPrimary,
        letterSpacing: -1.0,
      );
}

/// ─────────────────────────────────────────────────────────────────────────────
/// ThemeData Builder
/// ─────────────────────────────────────────────────────────────────────────────

ThemeData buildHermesTheme(AppearanceSettings appearance) {
  final bgColor = appearance.oledBlack ? const Color(0xFF000000) : const Color(0xFF121212);
  
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgColor,
    canvasColor: bgColor,
    primaryColor: HermesColors.accent,
    colorScheme: const ColorScheme.dark(
      primary: HermesColors.accent,
      secondary: HermesColors.accentWarm,
      tertiary: HermesColors.accentSoft,
      surface: HermesColors.surface,
      error: Color(0xFFCF6679),
    ),
    dividerColor: HermesColors.divider,
    textTheme: TextTheme(
      headlineLarge: HermesTypography.screenTitle,
      titleMedium: HermesTypography.blockTitle,
      bodyMedium: HermesTypography.body,
      bodySmall: HermesTypography.bodySmall,
      labelSmall: HermesTypography.metadata,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: HermesColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: HermesTypography.screenTitle,
      iconTheme: const IconThemeData(
        color: HermesColors.textSecondary,
        size: 22,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: HermesColors.background,
      selectedItemColor: HermesColors.textPrimary,
      unselectedItemColor: HermesColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showUnselectedLabels: true,
    ),
    splashColor: HermesColors.accent.withValues(alpha: 0.08),
    highlightColor: HermesColors.accent.withValues(alpha: 0.05),
    cardTheme: CardThemeData(
      color: HermesColors.surfaceElevated,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HermesRadius.md),
      ),
    ),
    iconTheme: const IconThemeData(
      color: HermesColors.textTertiary,
      size: 20,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: HermesColors.surfaceOverlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HermesRadius.lg),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: HermesColors.surfaceOverlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(HermesRadius.xl),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: HermesColors.surfaceElevated,
      contentTextStyle: HermesTypography.bodySmall,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HermesRadius.md),
      ),
    ),
  );
}
