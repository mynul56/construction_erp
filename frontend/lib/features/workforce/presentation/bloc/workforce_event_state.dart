import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, lateArrival, onLeave }

class WorkerAttendanceEntity extends Equatable {
  const WorkerAttendanceEntity({
    required this.workerId,
    required this.name,
    required this.role,
    required this.status,
    required this.checkInTime,
    required this.projectName,
    this.avatarInitial = 'W',
  });

  final String workerId;
  final String name;
  final String role;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final String projectName;
  final String avatarInitial;

  @override
  List<Object?> get props => [workerId, status];
}

// ─── Events ────────────────────────────────────────────────────────
abstract class WorkforceEvent extends Equatable {
  const WorkforceEvent();
  @override
  List<Object?> get props => [];
}

class AttendanceRequested extends WorkforceEvent {
  const AttendanceRequested(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

// ─── States ────────────────────────────────────────────────────────
abstract class WorkforceState extends Equatable {
  const WorkforceState();
  @override
  List<Object?> get props => [];
}

class WorkforceInitial extends WorkforceState {
  const WorkforceInitial();
}

class WorkforceLoading extends WorkforceState {
  const WorkforceLoading();
}

class WorkforceSuccess extends WorkforceState {
  const WorkforceSuccess(this.workers);
  final List<WorkerAttendanceEntity> workers;
  @override
  List<Object?> get props => [workers];
}

class WorkforceFailure extends WorkforceState {
  const WorkforceFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
