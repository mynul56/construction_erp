import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Generic shimmer skeleton. Pass [type] to switch between card, list, chart.
enum ShimmerType { card, listItem, chart, text }

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.type = ShimmerType.card,
    this.height,
    this.width,
  });

  final ShimmerType type;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.navyElevated : const Color(0xFFE0E6F0);
    final highlightColor =
        isDark ? AppColors.navyCard : const Color(0xFFF0F4FF);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: _buildShape(context),
    );
  }

  Widget _buildShape(BuildContext context) {
    switch (type) {
      case ShimmerType.card:
        return Container(
          height: height ?? 160,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      case ShimmerType.listItem:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 14,
                        color: Colors.white,
                        margin: const EdgeInsets.only(right: 60)),
                    const SizedBox(height: 8),
                    Container(
                        height: 11,
                        color: Colors.white,
                        margin: const EdgeInsets.only(right: 100)),
                  ],
                ),
              ),
            ],
          ),
        );
      case ShimmerType.chart:
        return Container(
          height: height ?? 200,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      case ShimmerType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 16, width: width ?? 200, color: Colors.white),
            const SizedBox(height: 8),
            Container(
                height: 12, width: (width ?? 200) * 0.7, color: Colors.white),
          ],
        );
    }
  }
}

class ShimmerKpiRow extends StatelessWidget {
  const ShimmerKpiRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => const SizedBox(
          width: 160,
          child: LoadingShimmer(type: ShimmerType.card),
        ),
      ),
    );
  }
}
