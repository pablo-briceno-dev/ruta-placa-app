import 'package:go_router/go_router.dart';
import 'package:ruta_placa/screens/calendar/calendar_screen.dart';
import 'package:ruta_placa/screens/home/home_screen.dart';
import 'package:ruta_placa/screens/route/route_screen.dart';
import 'package:ruta_placa/screens/settings/settings_screen.dart';
import 'package:ruta_placa/widgets/interceptor_screen_widget.dart';
import 'package:ruta_placa/widgets/main_shell_widget.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShellWidget(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const InterceptorScreenWidget(child: HomeScreen()),
        ),
        GoRoute(
          path: '/calendar',
          builder: (_, _) =>
              const InterceptorScreenWidget(child: CalendarScreen()),
        ),
        GoRoute(
          path: '/route',
          builder: (_, _) =>
              const InterceptorScreenWidget(child: RouteScreen()),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, _) => const InterceptorScreenWidget(
            viewAds: false,
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
