import 'package:equatable/equatable.dart';

class AnalyticsMetricsEntity extends Equatable {
  const AnalyticsMetricsEntity({
    required this.revenueByMonth,
    required this.costByMonth,
    required this.projectCompletion,
    required this.workerEfficiency,
    required this.categoryBreakdown,
  });

  final List<double> revenueByMonth;
  final List<double> costByMonth;
  final double projectCompletion;
  final double workerEfficiency;
  final Map<String, double> categoryBreakdown;

  @override
  List<Object?> get props => [revenueByMonth];
}

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class AnalyticsRequested extends AnalyticsEvent {
  const AnalyticsRequested();
}

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsSuccess extends AnalyticsState {
  const AnalyticsSuccess(this.metrics);
  final AnalyticsMetricsEntity metrics;
  @override
  List<Object?> get props => [metrics];
}

class AnalyticsFailure extends AnalyticsState {
  const AnalyticsFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
