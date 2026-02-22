import 'package:get_it/get_it.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_use_case.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/workforce/presentation/pages/workforce_page.dart';
import 'features/inventory/presentation/pages/inventory_page.dart';
import 'features/payroll/presentation/pages/payroll_page.dart';
import 'features/analytics/presentation/pages/analytics_page.dart';

final sl = GetIt.instance;

/// Register all services, repositories, use cases, and BLoCs.
/// WHY get_it: Zero framework coupling; BLoCs are lazily instantiated,
/// making it easy to scope them per screen without a Provider tree.
void setupInjection() {
  // ─── Repositories ──────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl());

  // ─── Use Cases ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));

  // ─── BLoCs (factories so each widget tree gets fresh instance) ─────
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));
  sl.registerFactory(() => DashboardBloc(getStats: sl()));

  // Inline BLoCs (co-located in pages — registered as factories)
  sl.registerFactory(() => WorkforceBloc());
  sl.registerFactory(() => InventoryBloc());
  sl.registerFactory(() => PayrollBloc());
  sl.registerFactory(() => AnalyticsBloc());
}
