import 'package:go_router/go_router.dart';
import 'package:ruta_placa/screens/home/home_screen.dart';
import 'package:ruta_placa/widgets/main_shell_widget.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShellWidget(child: child),
      routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
    ),
  ],
);