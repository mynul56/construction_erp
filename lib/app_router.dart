import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/workforce/presentation/pages/workforce_page.dart';
import 'features/inventory/presentation/pages/inventory_page.dart';
import 'features/payroll/presentation/pages/payroll_page.dart';
import 'features/analytics/presentation/pages/analytics_page.dart';

/// Shell scaffold hosting the bottom navigation bar + nested routes.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static const _navItems = [
    (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
    (Icons.engineering_rounded, Icons.engineering_outlined, 'Workforce'),
    (Icons.inventory_2_rounded, Icons.inventory_2_outlined, 'Inventory'),
    (Icons.payments_rounded, Icons.payments_outlined, 'Payroll'),
    (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1526) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 64 : 20),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final (activeIcon, inactiveIcon, label) = _navItems[i];
                final isActive = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => navigationShell.goBranch(i,
                        initialLocation: i == navigationShell.currentIndex),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated indicator dot
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: isActive ? 36 : 0,
                            height: isActive ? 4 : 0,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4FF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: isActive ? 1 : 0),
                            duration: const Duration(milliseconds: 200),
                            builder: (ctx, v, child) {
                              return Transform.scale(
                                scale: 1.0 + v * 0.12,
                                child: Icon(
                                  isActive ? activeIcon : inactiveIcon,
                                  color: isActive
                                      ? const Color(0xFF00D4FF)
                                      : (isDark ? Colors.white38 : Colors.grey),
                                  size: 22,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w400,
                              color: isActive
                                  ? const Color(0xFF00D4FF)
                                  : (isDark ? Colors.white38 : Colors.grey),
                            ),
                            child: Text(label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnLogin = state.uri.path == '/login';
      if (authState is AuthAuthenticated && isOnLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const DashboardPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/workforce',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const WorkforceAttendancePage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/inventory',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const InventoryOverviewPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/payroll',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const PayrollSummaryPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/analytics',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const AnalyticsPage(),
                transitionsBuilder: _fadeSlideTransition,
              ),
            ),
          ]),
        ],
      ),
    ],
  );
}

Widget _fadeSlideTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}
