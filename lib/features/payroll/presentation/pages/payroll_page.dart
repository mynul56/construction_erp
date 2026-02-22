import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/animations/animation_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../bloc/payroll_analytics_event_state.dart';

class PayrollSummaryPage extends StatefulWidget {
  const PayrollSummaryPage({super.key});

  @override
  State<PayrollSummaryPage> createState() => _PayrollSummaryPageState();
}

class _PayrollSummaryPageState extends State<PayrollSummaryPage> {
  @override
  void initState() {
    super.initState();
    context.read<PayrollBloc>().add(PayrollSummaryRequested(
        month: DateTime.now().month, year: DateTime.now().year));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0', 'en');

    return Scaffold(
      backgroundColor: isDark ? AppColors.navyDeep : AppColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<PayrollBloc, PayrollState>(
          builder: (context, state) {
            if (state is PayrollLoading) {
              return const _PayrollLoading();
            }
            if (state is PayrollSuccess) {
              return _PayrollBody(
                  summary: state.summary, fmt: fmt, isDark: isDark);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _PayrollLoading extends StatelessWidget {
  const _PayrollLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          LoadingShimmer(type: ShimmerType.card, height: 200),
          SizedBox(height: 16),
          LoadingShimmer(type: ShimmerType.chart, height: 220),
        ],
      ),
    );
  }
}

class _PayrollBody extends StatelessWidget {
  const _PayrollBody(
      {required this.summary, required this.fmt, required this.isDark});

  final PayrollSummaryEntity summary;
  final NumberFormat fmt;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final currentMonth = months[summary.month - 1];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payroll',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text('$currentMonth ${summary.year}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.cyan, letterSpacing: 1)),
                const SizedBox(height: 20),
                // Summary card
                StaggeredFadeSlide(
                  child:
                      _SummaryCard(summary: summary, fmt: fmt, isDark: isDark),
                ),
                const SizedBox(height: 20),
                // 6-month trend chart
                StaggeredFadeSlide(
                  delay: const Duration(milliseconds: 200),
                  child:
                      _TrendChart(data: summary.monthlyTrend, isDark: isDark),
                ),
                const SizedBox(height: 24),
                Text('Top Earners',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: StaggeredFadeSlide(
                delay: Duration(milliseconds: 300 + i * 70),
                child: _EarnerCard(
                    earner: summary.topEarners[i], fmt: fmt, isDark: isDark),
              ),
            ),
            childCount: summary.topEarners.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.summary, required this.fmt, required this.isDark});
  final PayrollSummaryEntity summary;
  final NumberFormat fmt;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.cyanGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withAlpha(64),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Payroll',
              style: TextStyle(
                  color: AppColors.navyDeep.withAlpha(180), fontSize: 13)),
          const SizedBox(height: 6),
          AnimatedCounter(
            value: summary.totalPayroll / 1000,
            suffix: 'K BDT',
            prefix: '৳',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDeep,
            ),
            fractionDigits: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                label: 'Paid',
                value: '৳${fmt.format(summary.paidAmount ~/ 1)}',
                color: AppColors.navyDeep,
              ),
              const SizedBox(width: 24),
              _MiniStat(
                label: 'Pending',
                value: '৳${fmt.format(summary.pendingAmount ~/ 1)}',
                color: AppColors.navyDeep,
              ),
              const Spacer(),
              _MiniStat(
                label: 'Workers',
                value: '${summary.workerCount}',
                color: AppColors.navyDeep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: color.withAlpha(160), fontSize: 11)),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 15)),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.data, required this.isDark});
  final List<double> data;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const monthLabels = ['Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('6-Month Trend', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: (isDark ? Colors.white : Colors.black).withAlpha(15),
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
                        if (i < 0 || i >= monthLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(monthLabels[i],
                            style: Theme.of(context).textTheme.labelSmall);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        '৳${(v / 1000).toStringAsFixed(0)}K',
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
                  LineChartBarData(
                    spots: List.generate(
                        data.length, (i) => FlSpot(i.toDouble(), data[i])),
                    isCurved: true,
                    color: AppColors.cyan,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.cyan,
                        strokeColor: isDark ? AppColors.navyCard : Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cyan.withAlpha(51),
                          AppColors.cyan.withAlpha(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnerCard extends StatelessWidget {
  const _EarnerCard(
      {required this.earner, required this.fmt, required this.isDark});
  final WorkerPaySummary earner;
  final NumberFormat fmt;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AppColors.purpleGradient),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(earner.avatarInitial,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(earner.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(earner.role, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text('৳${fmt.format(earner.amount ~/ 1)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.kpiGreen,
                    fontWeight: FontWeight.w800,
                  )),
        ],
      ),
    );
  }
}

// ─── PayrollBloc ────────────────────────────────────────────────────
class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  PayrollBloc() : super(const PayrollInitial()) {
    on<PayrollSummaryRequested>(_onRequested);
  }

  Future<void> _onRequested(
      PayrollSummaryRequested event, Emitter<PayrollState> emit) async {
    emit(const PayrollLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    emit(PayrollSuccess(_mockSummary(event.month, event.year)));
  }

  PayrollSummaryEntity _mockSummary(int month, int year) {
    return PayrollSummaryEntity(
      month: month,
      year: year,
      totalPayroll: 4850000,
      paidAmount: 3200000,
      pendingAmount: 1650000,
      workerCount: 200,
      monthlyTrend: [3800000, 4200000, 4100000, 4500000, 4700000, 4850000],
      topEarners: const [
        WorkerPaySummary(
            name: 'Rashid Khan',
            role: 'Senior Engineer',
            amount: 85000,
            avatarInitial: 'R'),
        WorkerPaySummary(
            name: 'Priya Das',
            role: 'Site Manager',
            amount: 72000,
            avatarInitial: 'P'),
        WorkerPaySummary(
            name: 'Md. Faruk',
            role: 'Structural Engineer',
            amount: 68000,
            avatarInitial: 'F'),
        WorkerPaySummary(
            name: 'Anita Roy',
            role: 'QA Supervisor',
            amount: 58000,
            avatarInitial: 'A'),
      ],
    );
  }
}
