import 'package:equatable/equatable.dart';

class InventoryItemEntity extends Equatable {
  const InventoryItemEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.lowStockThreshold,
    required this.location,
  });

  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double lowStockThreshold;
  final String location;

  bool get isLowStock => quantity <= lowStockThreshold;
  double get totalValue => quantity * unitPrice;

  @override
  List<Object?> get props => [id];
}

// ─── Events ────────────────────────────────────────────────────────
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class InventoryItemsRequested extends InventoryEvent {
  const InventoryItemsRequested();
}

class LowStockFiltered extends InventoryEvent {
  const LowStockFiltered();
}

// ─── States ────────────────────────────────────────────────────────
abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

class InventorySuccess extends InventoryState {
  const InventorySuccess(this.items, {this.showingLowStock = false});
  final List<InventoryItemEntity> items;
  final bool showingLowStock;
  @override
  List<Object?> get props => [items, showingLowStock];
}

class InventoryFailure extends InventoryState {
  const InventoryFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
