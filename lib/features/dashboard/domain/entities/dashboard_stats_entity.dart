class DashboardStatsEntity {
  const DashboardStatsEntity({
    required this.activeWorkers,
    required this.totalWorkers,
    required this.openTasks,
    required this.completedTasks,
    required this.totalInventoryValue,
    required this.pendingPayroll,
    required this.activeProjects,
    required this.siteSafetyScore,
    required this.recentProjects,
    required this.todayAttendance,
    required this.weeklyProgress,
  });

  final int activeWorkers;
  final int totalWorkers;
  final int openTasks;
  final int completedTasks;
  final double totalInventoryValue;
  final double pendingPayroll;
  final int activeProjects;
  final double siteSafetyScore;
  final List<ProjectSummary> recentProjects;
  final double todayAttendance; // percentage
  final List<double> weeklyProgress; // 7 values
}

class ProjectSummary {
  const ProjectSummary({
    required this.id,
    required this.name,
    required this.location,
    required this.progress,
    required this.dueDate,
    required this.status,
    required this.workerCount,
  });

  final String id;
  final String name;
  final String location;
  final double progress; // 0..1
  final DateTime dueDate;
  final ProjectStatus status;
  final int workerCount;
}

enum ProjectStatus { onTrack, delayed, critical, completed }
