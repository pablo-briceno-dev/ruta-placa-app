import 'package:go_router/go_router.dart';
import 'package:ruta_placa/screens/calendar/calendar_screen.dart';
import 'package:ruta_placa/screens/home/home_screen.dart';
import 'package:ruta_placa/screens/route/route_screen.dart';
import 'package:ruta_placa/screens/settings/settings_screen.dart';
import 'package:ruta_placa/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
        GoRoute(path: '/route', builder: (_, __) => const RouteScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);
