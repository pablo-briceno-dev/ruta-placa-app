import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/models/vehicle_restriction.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/services/rules_service.dart';
import 'package:ruta_placa/data/holidays_co.dart' as holidays;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // !DEBUG - DELETE ME
  void testBogota() {
    final restriction = VehicleRestriction.fromJson({
      "scheduleType": "rotating_alternating",
      "rotation": {
        "cycleStartDate": "2026-04-08",
        "weekdaysApply": [1, 2, 3, 4, 5],
        "rotationCycle": [
          [1, 2, 3, 4, 5],
          [6, 7, 8, 9, 0],
        ],
      },
      "morningStart": "06:00",
      "morningEnd": "20:00",
    });

    final fechas = {
      // 'Mié  8 abr → [1,2,3,4,5]': DateTime(2026, 4, 8),
      // 'Jue  9 abr → [6,7,8,9,0]': DateTime(2026, 4, 9), // ✅ confirmado
      // 'Vie 10 abr → [1,2,3,4,5]': DateTime(2026, 4, 10),
      // 'Lun 13 abr → [6,7,8,9,0]': DateTime(2026, 4, 13),
      // 'Mar 14 abr → [1,2,3,4,5]': DateTime(2026, 4, 14),
      // // 1 mayo = festivo jueves → todos los dígitos
      // 'Vie  1 may → NINGUNO': DateTime(2026, 5, 1),
      // 'Dom  3 may → TODOS': DateTime(2026, 5, 3),
      'Lun  4 may → [1,2,3,4,5]': DateTime(2026, 5, 4),
    };

    fechas.forEach((label, date) {
      final result = restriction.platesForDayWithContext(
        date: date,
        isHoliday: holidays.isHoliday(date),
      );
      debugPrint('$label → ${result.appliesToAll ? "TODOS" : result.plates}');
    });
  }
  // ! ========================================================================

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
              onPressed: () => testBogota(),
            ),
          ),
        ],
      ),
    );
  }
}
