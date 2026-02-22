import 'package:equatable/equatable.dart';

class PayrollSummaryEntity extends Equatable {
  const PayrollSummaryEntity({
    required this.month,
    required this.year,
    required this.totalPayroll,
    required this.paidAmount,
    required this.pendingAmount,
    required this.workerCount,
    required this.monthlyTrend,
    required this.topEarners,
  });

  final int month;
  final int year;
  final double totalPayroll;
  final double paidAmount;
  final double pendingAmount;
  final int workerCount;
  final List<double> monthlyTrend; // last 6 months
  final List<WorkerPaySummary> topEarners;

  @override
  List<Object?> get props => [month, year];
}

class WorkerPaySummary extends Equatable {
  const WorkerPaySummary({
    required this.name,
    required this.role,
    required this.amount,
    required this.avatarInitial,
  });
  final String name;
  final String role;
  final double amount;
  final String avatarInitial;

  @override
  List<Object?> get props => [name, amount];
}

// ─── Events / States ───────────────────────────────────────────────
abstract class PayrollEvent extends Equatable {
  const PayrollEvent();
  @override
  List<Object?> get props => [];
}

class PayrollSummaryRequested extends PayrollEvent {
  const PayrollSummaryRequested({required this.month, required this.year});
  final int month;
  final int year;
  @override
  List<Object?> get props => [month, year];
}

abstract class PayrollState extends Equatable {
  const PayrollState();
  @override
  List<Object?> get props => [];
}

class PayrollInitial extends PayrollState {
  const PayrollInitial();
}

class PayrollLoading extends PayrollState {
  const PayrollLoading();
}

class PayrollSuccess extends PayrollState {
  const PayrollSuccess(this.summary);
  final PayrollSummaryEntity summary;
  @override
  List<Object?> get props => [summary];
}

class PayrollFailure extends PayrollState {
  const PayrollFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─── Analytics ─────────────────────────────────────────────────────
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
