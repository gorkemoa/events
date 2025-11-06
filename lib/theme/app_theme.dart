import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Kurumsal Lacivert Paleti
  static const Color primary = Color(0xFF1C3C74); // Ana lacivert
  static const Color primaryLight = Color(0xFF2D5091);
  static const Color primaryDark = Color(0xFF0F2547);
  
  // Secondary Colors - Mavi Vurgu
  static const Color secondary = Color(0xFF0094C6); // Vurgu mavisi
  static const Color secondaryLight = Color(0xFF33A9D6);
  static const Color secondaryDark = Color(0xFF00739C);
  
  // Accent Colors - Altın (Premium vurgu için)
  static const Color accent = Color(0xFFC9A227);
  static const Color accentLight = Color(0xFFD4B547);
  static const Color accentDark = Color(0xFFA88818);
  
  // Neutral Colors - Koyu gri tonları
  static const Color textPrimary = Color(0xFF2C2C2C); // Koyu gri
  static const Color textSecondary = Color(0xFF5A5A5A);
  static const Color textTertiary = Color(0xFF8C8C8C);
  static const Color textHint = Color(0xFFB8B8B8);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5F5F5); // Açık gri
  static const Color surfaceSecondary = Color(0xFFF9F9F9);
  static const Color dividerColor = Color(0xFFE5E5E5);
  
  // Accent Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Text Styles - Profesyonel sans-serif hierarchy
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.1,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  static const TextStyle captionLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );
  
  static const TextStyle captionSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );
  
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Input Border Radius - Grid tabanlı, net ayrımlar
  static const double inputBorderRadius = 8;
  static const double cardBorderRadius = 12;
  static const double buttonBorderRadius = 8;
  
  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 20;
  static const double spacing2XL = 24;
  static const double spacing3XL = 32;
  
  // Shadows - Minimal, profesyonel
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get cardShadowHover => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  // ThemeData for Material App
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        fillColor: surfaceColor,
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textHint,
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(
            color: primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(
            color: error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: 14,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: error,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: dividerColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: 16,
          ),
          textStyle: buttonLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: dividerColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: buttonMedium,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(primary),
        side: const BorderSide(color: dividerColor),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        headlineMedium: headingMedium,
        headlineSmall: headingSmall,
        titleLarge: labelLarge,
        titleMedium: labelMedium,
        titleSmall: labelSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: buttonMedium,
      ),
    );
  }
}
