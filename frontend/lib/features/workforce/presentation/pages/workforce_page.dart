import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/animations/animation_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../bloc/workforce_event_state.dart';

class WorkforceAttendancePage extends StatefulWidget {
  const WorkforceAttendancePage({super.key});

  @override
  State<WorkforceAttendancePage> createState() =>
      _WorkforceAttendancePageState();
}

class _WorkforceAttendancePageState extends State<WorkforceAttendancePage> {
  @override
  void initState() {
    super.initState();
    context.read<WorkforceBloc>().add(AttendanceRequested(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.navyDeep : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WorkforceHeader(),
            // Stylised site map placeholder (ready for google_maps_flutter)
            _SiteMapPlaceholder(isDark: isDark),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Worker Attendance',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<WorkforceBloc, WorkforceState>(
                builder: (context, state) {
                  if (state is WorkforceLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 6,
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: const LoadingShimmer(type: ShimmerType.listItem),
                      ),
                    );
                  }
                  if (state is WorkforceSuccess) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.workers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => StaggeredFadeSlide(
                        delay: Duration(milliseconds: i * 60),
                        child: _WorkerCard(worker: state.workers[i]),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkforceHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workforce',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text('Attendance & Site Presence',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.cyan,
                    letterSpacing: 1,
                  )),
        ],
      ),
    );
  }
}

class _SiteMapPlaceholder extends StatelessWidget {
  const _SiteMapPlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.navyCard, AppColors.navyElevated]
              : [const Color(0xFFE8F4FF), const Color(0xFFD0E8FF)],
        ),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
        ),
      ),
      child: Stack(
        children: [
          // Grid lines
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(isDark: isDark),
          ),
          // Site markers
          Positioned(
            top: 60,
            left: 80,
            child: _SiteMarker(label: 'Tower A', color: AppColors.kpiGreen),
          ),
          Positioned(
            top: 40,
            right: 100,
            child: _SiteMarker(label: 'Overpass', color: AppColors.amber),
          ),
          Positioned(
            bottom: 50,
            left: 160,
            child: _SiteMarker(label: 'Complex', color: AppColors.cyan),
          ),
          // Label
          Positioned(
            top: 12,
            right: 14,
            child: GlassmorphicCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              blurSigma: 8,
              borderRadius: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined,
                      size: 12, color: AppColors.cyan),
                  const SizedBox(width: 4),
                  Text('Site Map',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.cyan)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : AppColors.navyDeep).withAlpha(15)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SiteMarker extends StatelessWidget {
  const _SiteMarker({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(230),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: color.withAlpha(77), blurRadius: 10, spreadRadius: 2)
            ],
          ),
          child: const Icon(Icons.construction_rounded,
              color: Colors.white, size: 16),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({required this.worker});
  final WorkerAttendanceEntity worker;

  Color _statusColor() {
    switch (worker.status) {
      case AttendanceStatus.present:
        return AppColors.kpiGreen;
      case AttendanceStatus.absent:
        return AppColors.kpiRedLight;
      case AttendanceStatus.lateArrival:
        return AppColors.amber;
      case AttendanceStatus.onLeave:
        return AppColors.purple;
    }
  }

  String _statusLabel() {
    switch (worker.status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.lateArrival:
        return 'Late';
      case AttendanceStatus.onLeave:
        return 'On Leave';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withAlpha(180),
                  statusColor.withAlpha(100)
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                worker.avatarInitial,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(worker.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(worker.role + ' · ' + worker.projectName,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(label: _statusLabel(), color: statusColor),
              if (worker.checkInTime != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatTime(worker.checkInTime!),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── WorkforceBloc ──────────────────────── (co-located for compactness)
class WorkforceBloc extends Bloc<WorkforceEvent, WorkforceState> {
  WorkforceBloc() : super(const WorkforceInitial()) {
    on<AttendanceRequested>(_onRequested);
  }

  Future<void> _onRequested(
      AttendanceRequested event, Emitter<WorkforceState> emit) async {
    emit(const WorkforceLoading());
    await Future.delayed(const Duration(milliseconds: 700));
    emit(WorkforceSuccess(_mockWorkers()));
  }

  List<WorkerAttendanceEntity> _mockWorkers() {
    final now = DateTime.now();
    return [
      WorkerAttendanceEntity(
          workerId: 'w1',
          name: 'Md. Hasan Ali',
          role: 'Mason',
          status: AttendanceStatus.present,
          checkInTime: now.subtract(const Duration(hours: 3, minutes: 12)),
          projectName: 'Tower Block A',
          avatarInitial: 'H'),
      WorkerAttendanceEntity(
          workerId: 'w2',
          name: 'Rahim Uddin',
          role: 'Electrician',
          status: AttendanceStatus.lateArrival,
          checkInTime: now.subtract(const Duration(hours: 1, minutes: 5)),
          projectName: 'Tower Block A',
          avatarInitial: 'R'),
      WorkerAttendanceEntity(
          workerId: 'w3',
          name: 'Karim Sheikh',
          role: 'Welder',
          status: AttendanceStatus.absent,
          checkInTime: null,
          projectName: 'Highway Overpass',
          avatarInitial: 'K'),
      WorkerAttendanceEntity(
          workerId: 'w4',
          name: 'Fatema Begum',
          role: 'Plumber',
          status: AttendanceStatus.present,
          checkInTime: now.subtract(const Duration(hours: 4)),
          projectName: 'Commercial Complex',
          avatarInitial: 'F'),
      WorkerAttendanceEntity(
          workerId: 'w5',
          name: 'Jamal Hossain',
          role: 'Carpenter',
          status: AttendanceStatus.onLeave,
          checkInTime: null,
          projectName: 'Highway Overpass',
          avatarInitial: 'J'),
      WorkerAttendanceEntity(
          workerId: 'w6',
          name: 'Nasrin Khatun',
          role: 'Supervisor',
          status: AttendanceStatus.present,
          checkInTime: now.subtract(const Duration(hours: 5, minutes: 30)),
          projectName: 'Commercial Complex',
          avatarInitial: 'N'),
    ];
  }
}
