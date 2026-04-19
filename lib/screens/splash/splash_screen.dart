import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _statusMessage = 'Iniciando...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _loadRules();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    final notifier = ref.read(rulesProvider.notifier);

    await notifier.loadWithProgress(
      onProgress: (msg) {
        if (mounted) setState(() => _statusMessage = msg);
      },
    );

    // ✅ Establecer ciudad por defecto si el usuario nunca eligió una
    await ref.read(selectedCityProvider.notifier).setDefaultIfEmpty('pasto');

    if (!mounted) return;

    final state = ref.read(rulesProvider);

    if (state.status == RulesStatus.error && state.cities.isEmpty) {
      // Sin datos y sin conexión → pantalla de error
      context.go('/no-data');
    } else {
      // Tiene datos (frescos o caché) → home
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.route_outlined,
                    size: 56,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'RutaPlaca',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Tu pico y placa siempre a mano',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: scheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statusMessage,
                  key: ValueKey(_statusMessage),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
