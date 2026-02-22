import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/presentation/pages/analytics_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event_state.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/inventory/presentation/pages/inventory_page.dart';
import 'features/payroll/presentation/pages/payroll_page.dart';
import 'features/workforce/presentation/pages/workforce_page.dart';
import 'injection_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait + portrait-up
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make status bar transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  setupInjection();
  runApp(const ConstructionErpApp());
}

class ConstructionErpApp extends StatefulWidget {
  const ConstructionErpApp({super.key});

  @override
  State<ConstructionErpApp> createState() => _ConstructionErpAppState();
}

class _ConstructionErpAppState extends State<ConstructionErpApp> {
  late final AuthBloc _authBloc;
  late final GoRouterWrapper _router;
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _router = GoRouterWrapper(buildRouter(_authBloc));
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<DashboardBloc>(create: (_) => sl<DashboardBloc>()),
        BlocProvider<WorkforceBloc>(create: (_) => sl<WorkforceBloc>()),
        BlocProvider<InventoryBloc>(create: (_) => sl<InventoryBloc>()),
        BlocProvider<PayrollBloc>(create: (_) => sl<PayrollBloc>()),
        BlocProvider<AnalyticsBloc>(create: (_) => sl<AnalyticsBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Constructio ERP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        routerConfig: _router.router,
        builder: (context, child) {
          // Inject a theme toggle button into every screen via overlaying
          // (In production, this would live in a Settings screen)
          return Stack(
            children: [
              child ?? const SizedBox.shrink(),
              // Floating theme toggle (top-right)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 80,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is! AuthAuthenticated) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () => setState(() {
                        _themeMode = _themeMode == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                      }),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(64),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _themeMode == ThemeMode.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Wrapper to hold GoRouter and keep it stable across rebuilds.
class GoRouterWrapper {
  GoRouterWrapper(this.router);
  final GoRouter router;
}
