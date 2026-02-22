import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import 'dashboard_event_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required GetDashboardStatsUseCase getStats})
      : _getStats = getStats,
        super(const DashboardInitial()) {
    on<DashboardStatsRequested>(_onStatsRequested);
    on<DashboardRefreshed>(_onRefreshed);
  }

  final GetDashboardStatsUseCase _getStats;

  Future<void> _onStatsRequested(
    DashboardStatsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await _getStats();
    result.fold(
      (failure) => emit(DashboardFailure(failure.message)),
      (stats) => emit(DashboardSuccess(stats)),
    );
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    // Don't show full loading on refresh — preserve last data
    final result = await _getStats();
    result.fold(
      (failure) => emit(DashboardFailure(failure.message)),
      (stats) => emit(DashboardSuccess(stats)),
    );
  }
}
