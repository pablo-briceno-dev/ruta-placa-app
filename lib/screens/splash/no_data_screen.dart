import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/rules_provider.dart';

class NoDataScreen extends ConsumerStatefulWidget {
  const NoDataScreen({super.key});

  @override
  ConsumerState<NoDataScreen> createState() => _NoDataScreenState();
}

class _NoDataScreenState extends ConsumerState<NoDataScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: scheme.onSurface.withOpacity(0.3),
              ),

              const SizedBox(height: 24),

              Text('Sin conexión', style: theme.textTheme.headlineSmall),

              const SizedBox(height: 8),

              Text(
                'RutaPlaca necesita descargar las reglas '
                'de pico y placa la primera vez que se usa. '
                'Conecta a internet e intenta de nuevo.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _retry,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_loading ? 'Descargando...' : 'Reintentar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _retry() async {
    setState(() => _loading = true);
    await ref.read(rulesProvider.notifier).loadWithProgress(onProgress: (_) {});
    setState(() => _loading = false);
  }
}
