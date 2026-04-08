import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/services/rules_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Column(
        children: [
          ListTile(
            title: Text('Versión de reglas'),
            subtitle: Text(RulesService.instance.cachedVersion ?? 'Sin datos'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(rulesProvider.notifier).refresh(),
            ),
          ),
        ],
      ),
    );
  }
}
