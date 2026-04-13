import 'package:flutter/material.dart';

class EmptyRoute extends StatelessWidget {
  final VoidCallback onAdd;

  const EmptyRoute({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.route_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text('Sin ciudades en tu ruta', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Agrega las ciudades por las que\npasarás en tu viaje',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Agregar primera ciudad'),
          ),
        ],
      ),
    );
  }
}
