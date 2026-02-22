import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/dashboard_stats_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase
    implements UseCaseNoParams<DashboardStatsEntity> {
  const GetDashboardStatsUseCase(this._repository);
  final DashboardRepository _repository;

  @override
  Future<Either<Failure, DashboardStatsEntity>> call() {
    return _repository.getStats();
  }
}
