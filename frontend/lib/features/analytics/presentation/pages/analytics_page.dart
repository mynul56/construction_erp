import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/animations/animation_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../bloc/analytics_event_state.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(const AnalyticsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.navyDeep : AppColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  LoadingShimmer(type: ShimmerType.card, height: 60),
                  SizedBox(height: 16),
                  LoadingShimmer(type: ShimmerType.chart, height: 240),
                  SizedBox(height: 16),
                  LoadingShimmer(type: ShimmerType.chart, height: 200),
                ]),
              );
            }
            if (state is AnalyticsSuccess) {
              return _AnalyticsBody(metrics: state.metrics, isDark: isDark);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.metrics, required this.isDark});
  final AnalyticsMetricsEntity metrics;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analytics',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text('Revenue & Performance',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.cyan, letterSpacing: 1)),
              ],
            ),
          ),
        ),
        // KPI summary row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: StaggeredFadeSlide(
              child: Row(
                children: [
                  _AnalyticsKpiTile(
                    label: 'Project Completion',
                    value: '${metrics.projectCompletion.toInt()}%',
                    color: AppColors.kpiGreen,
                    icon: Icons.check_circle_rounded,
                  ),
                  const SizedBox(width: 12),
                  _AnalyticsKpiTile(
                    label: 'Worker Efficiency',
                    value: '${metrics.workerEfficiency.toInt()}%',
                    color: AppColors.cyan,
                    icon: Icons.bolt_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Revenue vs Cost chart
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: StaggeredFadeSlide(
              delay: const Duration(milliseconds: 200),
              child: _RevenueChart(
                revenue: metrics.revenueByMonth,
                cost: metrics.costByMonth,
                isDark: isDark,
              ),
            ),
          ),
        ),
        // Category breakdown pie
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: StaggeredFadeSlide(
              delay: const Duration(milliseconds: 400),
              child: _CategoryPieChart(
                breakdown: metrics.categoryBreakdown,
                isDark: isDark,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _AnalyticsKpiTile extends StatelessWidget {
  const _AnalyticsKpiTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                        begin: 0, end: double.parse(value.replaceAll('%', ''))),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutExpo,
                    builder: (_, v, __) => Text(
                      '${v.toInt()}%',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: color, fontWeight: FontWeight.w800),
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

class _RevenueChart extends StatelessWidget {
  const _RevenueChart(
      {required this.revenue, required this.cost, required this.isDark});
  final List<double> revenue;
  final List<double> cost;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const months = ['Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Revenue vs Cost',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              _Legend(color: AppColors.cyan, label: 'Revenue'),
              const SizedBox(width: 12),
              _Legend(color: AppColors.kpiOrange, label: 'Cost'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: (isDark ? Colors.white : Colors.black).withAlpha(13),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= months.length)
                          return const SizedBox.shrink();
                        return Text(months[i],
                            style: Theme.of(context).textTheme.labelSmall);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (v, _) => Text(
                        '৳${(v / 1000000).toStringAsFixed(1)}M',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontSize: 9),
                      ),
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  _line(revenue, AppColors.cyan),
                  _line(cost, AppColors.kpiOrange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withAlpha(38), color.withAlpha(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 3,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart({required this.breakdown, required this.isDark});
  final Map<String, double> breakdown;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.cyan,
      AppColors.kpiGreen,
      AppColors.kpiOrange,
      AppColors.purple,
      AppColors.amber,
    ];
    final entries = breakdown.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cost Breakdown', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    sections: List.generate(entries.length, (i) {
                      return PieChartSectionData(
                        value: entries[i].value,
                        color: colors[i % colors.length],
                        radius: 22,
                        showTitle: false,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(entries.length, (i) {
                    final total = breakdown.values.reduce((a, b) => a + b);
                    final pct = (entries[i].value / total * 100).toInt();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(entries[i].key,
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                          Text('$pct%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colors[i % colors.length])),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── AnalyticsBloc ──────────────────────────────────────────────────
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(const AnalyticsInitial()) {
    on<AnalyticsRequested>(_onRequested);
  }

  Future<void> _onRequested(
      AnalyticsRequested event, Emitter<AnalyticsState> emit) async {
    emit(const AnalyticsLoading());
    await Future.delayed(const Duration(milliseconds: 900));
    emit(AnalyticsSuccess(AnalyticsMetricsEntity(
      revenueByMonth: [
        12500000,
        13800000,
        11900000,
        15200000,
        14800000,
        16100000
      ],
      costByMonth: [9800000, 10200000, 9100000, 11500000, 10900000, 11800000],
      projectCompletion: 68,
      workerEfficiency: 82,
      categoryBreakdown: const {
        'Labor': 38,
        'Materials': 30,
        'Equipment': 15,
        'Overhead': 12,
        'Safety': 5,
      },
    )));
  }
}
