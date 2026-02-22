import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/animation_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event_state.dart';
import '../widgets/kpi_card_3d.dart';
import '../widgets/project_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardStatsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.navyDeep : AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.cyan,
          backgroundColor: isDark ? AppColors.navyCard : Colors.white,
          onRefresh: () async {
            context.read<DashboardBloc>().add(const DashboardRefreshed());
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return _LoadingView();
              }
              if (state is DashboardFailure) {
                return _ErrorView(message: state.message);
              }
              if (state is DashboardSuccess) {
                return _SuccessView(stats: state.stats);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// ── Loading View ─────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        _Header(userName: '...', isLoading: true),
        const ShimmerKpiRow(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child:
                    const LoadingShimmer(type: ShimmerType.card, height: 130),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context
                .read<DashboardBloc>()
                .add(const DashboardStatsRequested()),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ── Success View ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.stats});
  final DashboardStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final kpiCards = buildKpiCards(stats);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _Header(userName: 'Arjun Mehta'),
        ),
        // ── KPI Cards Horizontal Row ──────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: kpiCards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) => StaggeredFadeSlide(
                delay: Duration(milliseconds: 100 + i * 80),
                child: KpiCard3D(data: kpiCards[i]),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        // ── Attendance Ring + Weekly Chart ────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StaggeredFadeSlide(
              delay: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Expanded(
                      child: _AttendanceRing(percent: stats.todayAttendance)),
                  const SizedBox(width: 14),
                  Expanded(child: _WeeklyChart(data: stats.weeklyProgress)),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        // ── Section Header ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StaggeredFadeSlide(
              delay: const Duration(milliseconds: 500),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active Projects',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View all'),
                  ),
                ],
              ),
            ),
          ),
        ),
        // ── Project Cards ──────────────────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => ProjectCard(
              project: stats.recentProjects[i],
              index: i,
            ),
            childCount: stats.recentProjects.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.userName, this.isLoading = false});
  final String userName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.cyan,
                        letterSpacing: 1,
                      ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? const LoadingShimmer(
                        type: ShimmerType.text, height: 28, width: 180)
                    : Text(
                        userName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
              ],
            ),
          ),
          // Notification bell
          _NotifBell(isDark: isDark),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.cyanGradient,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfilePage(),
                        ),
                      );
                    },
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.navyDeep,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }
}

class _NotifBell extends StatelessWidget {
  const _NotifBell({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_outlined,
            color: isDark ? Colors.white : AppColors.navyDeep,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.kpiRedLight,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Attendance Ring ───────────────────────────────────────────────────────────

class _AttendanceRing extends StatelessWidget {
  const _AttendanceRing({required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Column(
        children: [
          Text('Today\'s Attendance',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 0,
                centerSpaceRadius: 32,
                sections: [
                  PieChartSectionData(
                    value: percent * 100,
                    color: AppColors.cyan,
                    radius: 14,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (1 - percent) * 100,
                    color: isDark
                        ? AppColors.navyElevated
                        : AppColors.outlineLight,
                    radius: 14,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent * 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutExpo,
            builder: (_, v, __) => Text(
              '${v.toInt()}%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.cyan, fontWeight: FontWeight.w800),
            ),
          ),
          Text('Present', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ── Weekly Progress Chart ─────────────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data});
  final List<double> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Progress',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                        days[v.toInt()],
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(data.length, (i) {
                  final isToday = i == 6;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i] * 100,
                        color: isToday
                            ? AppColors.cyan
                            : AppColors.kpiBlue.withAlpha(153),
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
