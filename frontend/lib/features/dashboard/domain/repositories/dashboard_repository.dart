import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/dashboard_stats_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStatsEntity>> getStats();
}
