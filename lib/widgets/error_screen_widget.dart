import 'package:flutter/material.dart';

class ErrorScreenWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const ErrorScreenWidget({super.key, this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ⚠️ Icono
              Icon(Icons.cloud_off, size: 80, color: theme.colorScheme.error),

              const SizedBox(height: 24),

              // 🧾 Título
              Text(
                'Error al cargar datos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 📄 Mensaje
              Text(
                message ??
                    'No se pudieron descargar las reglas de pico y placa.\nVerifica tu conexión a internet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // 🔄 Botón reintentar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ),

              const SizedBox(height: 12),

              // 💡 Botón opcional (seguir sin internet)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Continuar sin conexión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
