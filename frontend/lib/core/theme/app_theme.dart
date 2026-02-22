import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _buildTheme(Brightness.dark);
  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.cyan,
      onPrimary: AppColors.navyDeep,
      primaryContainer: AppColors.cyanDark,
      onPrimaryContainer: AppColors.navyDeep,
      secondary: AppColors.amber,
      onSecondary: AppColors.navyDeep,
      secondaryContainer: AppColors.amberDark,
      onSecondaryContainer: AppColors.navyDeep,
      tertiary: AppColors.purple,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: isDark ? AppColors.navySurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
      surfaceContainerHighest:
          isDark ? AppColors.navyCard : AppColors.lightCard,
      outline: isDark ? AppColors.outlineDark : AppColors.outlineLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme(isDark),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.navyCard : AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      scaffoldBackgroundColor:
          isDark ? AppColors.navyDeep : AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.navyDeep,
        ),
        titleTextStyle: AppTypography.textTheme(isDark).titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.navyDeep,
            ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.navyCard : Colors.white,
        selectedItemColor: AppColors.cyan,
        unselectedItemColor:
            isDark ? AppColors.onSurfaceDark.withAlpha(128) : Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.navyCard : AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.navyDeep,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.textTheme(isDark).labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.navyCard : AppColors.lightCard,
        selectedColor: AppColors.cyan.withAlpha(51),
        side: BorderSide(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
        thickness: 1,
      ),
      extensions: [
        AppColorExtension(
          kpiBlue: AppColors.kpiBlue,
          kpiGreen: AppColors.kpiGreen,
          kpiOrange: AppColors.kpiOrange,
          kpiPurple: AppColors.purple,
          glassColor:
              isDark ? Colors.white.withAlpha(13) : Colors.white.withAlpha(179),
          glassBorder:
              isDark ? Colors.white.withAlpha(25) : Colors.white.withAlpha(128),
        ),
      ],
    );
  }
}

/// Custom theme extension for ERP-specific colors
@immutable
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  const AppColorExtension({
    required this.kpiBlue,
    required this.kpiGreen,
    required this.kpiOrange,
    required this.kpiPurple,
    required this.glassColor,
    required this.glassBorder,
  });

  final Color kpiBlue;
  final Color kpiGreen;
  final Color kpiOrange;
  final Color kpiPurple;
  final Color glassColor;
  final Color glassBorder;

  @override
  AppColorExtension copyWith({
    Color? kpiBlue,
    Color? kpiGreen,
    Color? kpiOrange,
    Color? kpiPurple,
    Color? glassColor,
    Color? glassBorder,
  }) {
    return AppColorExtension(
      kpiBlue: kpiBlue ?? this.kpiBlue,
      kpiGreen: kpiGreen ?? this.kpiGreen,
      kpiOrange: kpiOrange ?? this.kpiOrange,
      kpiPurple: kpiPurple ?? this.kpiPurple,
      glassColor: glassColor ?? this.glassColor,
      glassBorder: glassBorder ?? this.glassBorder,
    );
  }

  @override
  AppColorExtension lerp(AppColorExtension? other, double t) {
    if (other is! AppColorExtension) return this;
    return AppColorExtension(
      kpiBlue: Color.lerp(kpiBlue, other.kpiBlue, t)!,
      kpiGreen: Color.lerp(kpiGreen, other.kpiGreen, t)!,
      kpiOrange: Color.lerp(kpiOrange, other.kpiOrange, t)!,
      kpiPurple: Color.lerp(kpiPurple, other.kpiPurple, t)!,
      glassColor: Color.lerp(glassColor, other.glassColor, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
    );
  }
}
