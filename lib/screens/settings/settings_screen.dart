import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/services/rules_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void testPasto() {
    // Simula lo que vendría del JSON de GitHub
    final restriction = VehicleRestriction.fromJson({
      "scheduleType": "rotating_weekly_daily",
      "rotation": {
        "cycleStartDate": "2026-04-06",
        "cycleLengthDays": 10,
        "weekdaysApply": [1, 2, 3, 4, 5],
        "rotationCycle": [
          [0, 1],
          [2, 3],
          [4, 5],
          [6, 7],
          [8, 9],
        ],
      },
      "morningStart": "07:00",
      "morningEnd": "09:00",
      "afternoonStart": "17:00",
      "afternoonEnd": "19:00",
      "note": null,
    });

    final fechas = {
      'Lun  6 abr': DateTime(2026, 4, 6),
      'Mar  7 abr': DateTime(2026, 4, 7),
      'Mié  8 abr': DateTime(2026, 4, 8), // debe dar [4, 5]
      'Jue  9 abr': DateTime(2026, 4, 9),
      'Vie 10 abr': DateTime(2026, 4, 10),
      'Lun 13 abr': DateTime(2026, 4, 13), // debe dar [2, 3]
      'Mar 14 abr': DateTime(2026, 4, 14), // debe dar [4, 5]
      'Mié 15 abr': DateTime(2026, 4, 15), // debe dar [6, 7]
      'Jue 16 abr': DateTime(2026, 4, 16), // debe dar [8, 9]
      'Vie 17 abr': DateTime(2026, 4, 17), // debe dar [0, 1]
    };

    fechas.forEach((label, date) {
      final plates = restriction.platesForDay(date);
      debugPrint('$label → $plates');
    });
  }

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
              // onPressed: () => ref.read(rulesProvider.notifier).refresh(),
              onPressed: () => testPasto(),
            ),
          ),
        ],
      ),
    );
  }
}
