import 'package:flutter/material.dart';
import '../../../../core/animations/animation_utils.dart';
import '../../../../core/animations/tilt_card_3d.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

/// Data model for a KPI card config.
class KpiCardData {
  const KpiCardData({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.gradientColors,
    required this.trend,
    required this.trendLabel,
  });

  final String title;
  final double value;
  final String suffix;
  final IconData icon;
  final List<Color> gradientColors;
  final double trend; // positive or negative
  final String trendLabel;
}

/// 3D tilt KPI card with animated counter.
class KpiCard3D extends StatelessWidget {
  const KpiCard3D({super.key, required this.data});

  final KpiCardData data;

  @override
  Widget build(BuildContext context) {
    return TiltCard3D(
      maxTiltDegrees: 10,
      glowColor: data.gradientColors.first,
      child: Container(
        width: 168,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: data.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: data.gradientColors.first.withAlpha(64),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 18),
            // Animated value
            AnimatedCounter(
              value: data.value,
              suffix: data.suffix,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              fractionDigits: data.value % 1 != 0 ? 1 : 0,
            ),
            const SizedBox(height: 4),
            Text(
              data.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(179),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            // Trend badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    data.trend >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: data.trend >= 0
                        ? const Color(0xFF00C896)
                        : AppColors.error,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data.trendLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Factory to build KPI cards from DashboardStatsEntity
List<KpiCardData> buildKpiCards(DashboardStatsEntity stats) {
  return [
    KpiCardData(
      title: 'Active Workers',
      value: stats.activeWorkers.toDouble(),
      suffix: '',
      icon: Icons.engineering_rounded,
      gradientColors: AppColors.cyanGradient,
      trend: 12,
      trendLabel: '+12 today',
    ),
    KpiCardData(
      title: 'Inventory Value',
      value: stats.totalInventoryValue / 1000,
      suffix: 'K',
      icon: Icons.inventory_2_rounded,
      gradientColors: AppColors.greenGradient,
      trend: 3.4,
      trendLabel: '+3.4%',
    ),
    KpiCardData(
      title: 'Open Tasks',
      value: stats.openTasks.toDouble(),
      suffix: '',
      icon: Icons.task_alt_rounded,
      gradientColors: AppColors.orangeGradient,
      trend: -5,
      trendLabel: '5 overdue',
    ),
    KpiCardData(
      title: 'Safety Score',
      value: stats.siteSafetyScore,
      suffix: '%',
      icon: Icons.health_and_safety_rounded,
      gradientColors: AppColors.purpleGradient,
      trend: 2.1,
      trendLabel: '+2.1%',
    ),
  ];
}
