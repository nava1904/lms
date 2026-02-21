import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional EdTech LMS Design (v2) – matches ingestion _pipe_lines/Professional EdTech LMS version 2.
/// Primary #2563EB, background #F8FAFC, foreground #1E293B, border #E2E8F0, muted #64748B.
class LMSTheme {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF3B82F6);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color onSurfaceColor = Color(0xFF1E293B);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  /// Design tokens from reference theme.css
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color accentColor = Color(0xFFEFF6FF);
  static const Color gradientStart = Color(0xFFEFF6FF);
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;

  /// Standard spacing (8, 12, 16, 24, 32).
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  /// Standard padding.
  static const EdgeInsets paddingSm = EdgeInsets.all(8);
  static const EdgeInsets paddingMd = EdgeInsets.all(16);
  static const EdgeInsets paddingLg = EdgeInsets.all(24);
  /// Card: white, border, shadow 0 10px 20px rgba(0,0,0,0.03)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
  ];
  static List<BoxShadow> get cardShadowHover => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 10)),
  ];
  /// Sidebar: admin dark
  static const Color sidebarDarkBg = Color(0xFF1E293B);
  static const Color sidebarDarkBorder = Color(0xFF334155);
  static const Color sidebarDarkText = Color(0xFFF1F5F9);
  static const Color sidebarDarkMuted = Color(0xFF94A3B8);

  static const Color darkSurfaceColor = Color(0xFF0F172A);
  static const Color darkOnSurfaceColor = Color(0xFFF1F5F9);
  static const Color darkBorderColor = Color(0xFF334155);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: surfaceColor,
      textTheme: _buildTextTheme(),
      primaryTextTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        labelStyle: GoogleFonts.inter(color: onSurfaceColor),
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade600),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: mutedForeground.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: mutedForeground.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurfaceColor,
        contentTextStyle: GoogleFonts.inter(color: surfaceColor, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        surface: darkSurfaceColor,
        onSurface: darkOnSurfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: darkSurfaceColor,
      textTheme: _buildTextThemeDark(),
      primaryTextTheme: _buildTextThemeDark(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkOnSurfaceColor,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurfaceColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorderColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }

  static TextTheme _buildTextThemeDark() {
    return TextTheme(
      headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: darkOnSurfaceColor),
      headlineMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: darkOnSurfaceColor),
      titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: darkOnSurfaceColor),
      titleMedium: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500, color: darkOnSurfaceColor),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: darkOnSurfaceColor),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: darkOnSurfaceColor),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: darkOnSurfaceColor),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: darkOnSurfaceColor),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: onSurfaceColor,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: onSurfaceColor,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurfaceColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: onSurfaceColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: onSurfaceColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: onSurfaceColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurfaceColor,
      ),
    );
  }
}
