import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<Either<Failure, DashboardStatsEntity>> getStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      return Right(_mockStats());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  DashboardStatsEntity _mockStats() {
    return DashboardStatsEntity(
      activeWorkers: 148,
      totalWorkers: 200,
      openTasks: 34,
      completedTasks: 217,
      totalInventoryValue: 2340000,
      pendingPayroll: 485000,
      activeProjects: 7,
      siteSafetyScore: 94.5,
      todayAttendance: 0.74,
      weeklyProgress: [0.6, 0.72, 0.65, 0.80, 0.78, 0.85, 0.74],
      recentProjects: [
        ProjectSummary(
          id: 'p1',
          name: 'Tower Block A',
          location: 'Dhaka, BD',
          progress: 0.72,
          dueDate: DateTime(2026, 6, 15),
          status: ProjectStatus.onTrack,
          workerCount: 52,
        ),
        ProjectSummary(
          id: 'p2',
          name: 'Highway Overpass',
          location: 'Chattogram, BD',
          progress: 0.38,
          dueDate: DateTime(2026, 4, 20),
          status: ProjectStatus.delayed,
          workerCount: 34,
        ),
        ProjectSummary(
          id: 'p3',
          name: 'Commercial Complex',
          location: 'Sylhet, BD',
          progress: 0.91,
          dueDate: DateTime(2026, 3, 10),
          status: ProjectStatus.onTrack,
          workerCount: 28,
        ),
        ProjectSummary(
          id: 'p4',
          name: 'Water Treatment Plant',
          location: 'Rajshahi, BD',
          progress: 0.15,
          dueDate: DateTime(2026, 8, 30),
          status: ProjectStatus.critical,
          workerCount: 19,
        ),
      ],
    );
  }
}
