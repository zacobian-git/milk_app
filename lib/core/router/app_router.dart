import 'package:go_router/go_router.dart';
import 'package:milk_app/core/widgets/app_shell.dart';
import 'package:milk_app/features/calendar/presentation/calendar_screen.dart';
import 'package:milk_app/features/home/presentation/home_screen.dart';
import 'package:milk_app/features/payments/presentation/payments_screen.dart';
import 'package:milk_app/features/reports/presentation/reports_screen.dart';
import 'package:milk_app/features/settings/presentation/settings_screen.dart';
import 'package:milk_app/features/vendors/presentation/vendor_form_screen.dart';
import 'package:milk_app/features/vendors/presentation/vendor_list_screen.dart';
import 'package:milk_app/features/vendors/presentation/vendor_rate_history_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/vendors',
              builder: (context, state) => const VendorListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const VendorFormScreen(),
                ),
                GoRoute(
                  path: ':vendorId/edit',
                  builder: (context, state) => VendorFormScreen(
                    vendorId: int.parse(state.pathParameters['vendorId']!),
                  ),
                ),
                GoRoute(
                  path: ':vendorId/rates',
                  builder: (context, state) => VendorRateHistoryScreen(
                    vendorId: int.parse(state.pathParameters['vendorId']!),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/payments',
              builder: (context, state) => const PaymentsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
