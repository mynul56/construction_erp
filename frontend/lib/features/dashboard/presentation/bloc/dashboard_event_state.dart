import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

// ─── Events ────────────────────────────────────────────────────────────────

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class DashboardStatsRequested extends DashboardEvent {
  const DashboardStatsRequested();
}

class DashboardRefreshed extends DashboardEvent {
  const DashboardRefreshed();
}

// ─── States ────────────────────────────────────────────────────────────────

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardSuccess extends DashboardState {
  const DashboardSuccess(this.stats);
  final DashboardStatsEntity stats;

  @override
  List<Object?> get props => [stats];
}

class DashboardFailure extends DashboardState {
  const DashboardFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
