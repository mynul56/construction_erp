import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/animations/animation_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../bloc/inventory_event_state.dart';

class InventoryOverviewPage extends StatefulWidget {
  const InventoryOverviewPage({super.key});

  @override
  State<InventoryOverviewPage> createState() => _InventoryOverviewPageState();
}

class _InventoryOverviewPageState extends State<InventoryOverviewPage> {
  bool _showLowStock = false;

  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(const InventoryItemsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.navyDeep : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inventory',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text('Material Management',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: AppColors.cyan, letterSpacing: 1)),
                    ],
                  ),
                  // Filter toggle
                  GestureDetector(
                    onTap: () {
                      setState(() => _showLowStock = !_showLowStock);
                      context.read<InventoryBloc>().add(_showLowStock
                          ? const LowStockFiltered()
                          : const InventoryItemsRequested());
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showLowStock
                            ? AppColors.kpiRedLight.withAlpha(26)
                            : (isDark ? AppColors.navyCard : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showLowStock
                              ? AppColors.kpiRedLight
                              : (isDark
                                  ? AppColors.outlineDark
                                  : AppColors.outlineLight),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 14,
                              color: _showLowStock
                                  ? AppColors.kpiRedLight
                                  : Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Low Stock',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: _showLowStock
                                        ? AppColors.kpiRedLight
                                        : null),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  if (state is InventoryLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 5,
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: const LoadingShimmer(
                            type: ShimmerType.card, height: 100),
                      ),
                    );
                  }
                  if (state is InventorySuccess) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => StaggeredFadeSlide(
                        delay: Duration(milliseconds: i * 60),
                        child:
                            _InventoryItemCard(item: state.items[i], index: i),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  const _InventoryItemCard({required this.item, required this.index});
  final InventoryItemEntity item;
  final int index;

  static const _categoryIcons = {
    'Steel': Icons.cable_rounded,
    'Cement': Icons.local_florist_rounded,
    'Timber': Icons.forest_rounded,
    'Safety': Icons.health_and_safety_rounded,
    'Electrical': Icons.electrical_services_rounded,
    'Plumbing': Icons.plumbing_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradients = [
      AppColors.cyanGradient,
      AppColors.greenGradient,
      AppColors.orangeGradient,
      AppColors.purpleGradient,
      AppColors.amberGradient,
    ];
    final grad = gradients[index % gradients.length];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isLowStock
              ? AppColors.kpiRedLight.withAlpha(128)
              : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
          width: item.isLowStock ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Category icon panel
          Container(
            width: 64,
            margin: const EdgeInsets.all(10),
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: grad),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _categoryIcons[item.category] ?? Icons.inventory_2_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      if (item.isLowStock)
                        StatusBadge(
                            label: 'Low Stock', color: AppColors.kpiRedLight),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${item.location} · ${item.category}',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatChip(
                          label: '${item.quantity.toInt()} ${item.unit}',
                          icon: Icons.numbers_rounded),
                      const SizedBox(width: 8),
                      _StatChip(
                          label:
                              '৳${(item.totalValue / 1000).toStringAsFixed(1)}K',
                          icon: Icons.attach_money_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.cyan),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

// ─── InventoryBloc ──────────────────────────────────────────────────
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc() : super(const InventoryInitial()) {
    on<InventoryItemsRequested>(_onItemsRequested);
    on<LowStockFiltered>(_onLowStockFiltered);
  }

  final List<InventoryItemEntity> _allItems = _mockItems();

  Future<void> _onItemsRequested(
      InventoryItemsRequested event, Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(InventorySuccess(_allItems));
  }

  Future<void> _onLowStockFiltered(
      LowStockFiltered event, Emitter<InventoryState> emit) async {
    final low = _allItems.where((i) => i.isLowStock).toList();
    emit(InventorySuccess(low, showingLowStock: true));
  }

  static List<InventoryItemEntity> _mockItems() => [
        const InventoryItemEntity(
            id: 'i1',
            name: 'TMT Steel Bars',
            category: 'Steel',
            quantity: 450,
            unit: 'ton',
            unitPrice: 85000,
            lowStockThreshold: 100,
            location: 'Warehouse A'),
        const InventoryItemEntity(
            id: 'i2',
            name: 'Portland Cement',
            category: 'Cement',
            quantity: 30,
            unit: 'bags',
            unitPrice: 450,
            lowStockThreshold: 50,
            location: 'Site B'),
        const InventoryItemEntity(
            id: 'i3',
            name: 'Teak Timber',
            category: 'Timber',
            quantity: 280,
            unit: 'pcs',
            unitPrice: 1200,
            lowStockThreshold: 50,
            location: 'Warehouse B'),
        const InventoryItemEntity(
            id: 'i4',
            name: 'Safety Helmets',
            category: 'Safety',
            quantity: 15,
            unit: 'units',
            unitPrice: 800,
            lowStockThreshold: 30,
            location: 'Site A'),
        const InventoryItemEntity(
            id: 'i5',
            name: 'Copper Wire',
            category: 'Electrical',
            quantity: 120,
            unit: 'm',
            unitPrice: 120,
            lowStockThreshold: 40,
            location: 'Warehouse A'),
        const InventoryItemEntity(
            id: 'i6',
            name: 'PVC Pipes',
            category: 'Plumbing',
            quantity: 200,
            unit: 'pcs',
            unitPrice: 350,
            lowStockThreshold: 60,
            location: 'Site B'),
      ];
}
