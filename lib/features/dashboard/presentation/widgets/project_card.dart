import 'package:flutter/material.dart';
import '../../../../core/animations/animation_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import 'package:intl/intl.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.index,
    this.onTap,
  });

  final ProjectSummary project;
  final int index;
  final VoidCallback? onTap;

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.onTrack:
        return AppColors.kpiGreen;
      case ProjectStatus.delayed:
        return AppColors.amber;
      case ProjectStatus.critical:
        return AppColors.kpiRedLight;
      case ProjectStatus.completed:
        return AppColors.cyan;
    }
  }

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.onTrack:
        return 'On Track';
      case ProjectStatus.delayed:
        return 'Delayed';
      case ProjectStatus.critical:
        return 'Critical';
      case ProjectStatus.completed:
        return 'Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(project.status);

    return StaggeredFadeSlide(
      delay: Duration(milliseconds: 200 + index * 100),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Subtle left accent
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          StatusBadge(
                            label: _statusLabel(project.status),
                            color: statusColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(128)),
                          const SizedBox(width: 4),
                          Text(
                            project.location,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Icon(Icons.people_outline_rounded,
                              size: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(128)),
                          const SizedBox(width: 4),
                          Text(
                            '${project.workerCount} workers',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      '${(project.progress * 100).toInt()}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                              color: statusColor,
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: TweenAnimationBuilder<double>(
                                    tween:
                                        Tween(begin: 0, end: project.progress),
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    curve: Curves.easeOutCubic,
                                    builder: (_, v, __) =>
                                        LinearProgressIndicator(
                                      value: v,
                                      minHeight: 6,
                                      backgroundColor:
                                          statusColor.withAlpha(38),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          statusColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Due',
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMM d').format(project.dueDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
