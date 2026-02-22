import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand / Primary ───────────────────────────────────────────────
  static const Color navyDeep = Color(0xFF0A0F1E);
  static const Color navySurface = Color(0xFF0D1526);
  static const Color navyCard = Color(0xFF14213D);
  static const Color navyElevated = Color(0xFF1C2E50);

  static const Color cyan = Color(0xFF00D4FF);
  static const Color cyanDark = Color(0xFF0099CC);
  static const Color cyanGlow = Color(0x3300D4FF);

  static const Color amber = Color(0xFFFFB300);
  static const Color amberDark = Color(0xFFCC8F00);
  static const Color purple = Color(0xFF7C5CE0);

  // ─── KPI Palette ───────────────────────────────────────────────────
  static const Color kpiBlue = Color(0xFF3D8EF0);
  static const Color kpiGreen = Color(0xFF00C896);
  static const Color kpiOrange = Color(0xFFFF6B35);
  static const Color kpiRedLight = Color(0xFFFF5252);

  // ─── Semantic ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF3D8EF0);

  // ─── Light Theme ───────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F7FC);
  static const Color lightSurface = Color(0xFFF5F7FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF0A0F1E);
  static const Color outlineLight = Color(0xFFE0E6F0);

  // ─── Dark Theme ────────────────────────────────────────────────────
  static const Color onSurfaceDark = Color(0xFFE8EDF5);
  static const Color outlineDark = Color(0xFF1E2D4A);

  // ─── Gradients ─────────────────────────────────────────────────────
  static const List<Color> dashboardGradient = [navySurface, navyDeep];
  static const List<Color> cyanGradient = [
    Color(0xFF00D4FF),
    Color(0xFF007AFF)
  ];
  static const List<Color> greenGradient = [
    Color(0xFF00C896),
    Color(0xFF00876A)
  ];
  static const List<Color> orangeGradient = [
    Color(0xFFFF6B35),
    Color(0xFFCC4400)
  ];
  static const List<Color> purpleGradient = [
    Color(0xFF7C5CE0),
    Color(0xFF5038B0)
  ];
  static const List<Color> amberGradient = [
    Color(0xFFFFB300),
    Color(0xFFCC8F00)
  ];
}
