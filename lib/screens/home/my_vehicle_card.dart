import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/core/helpers/restriction_reason_ext.dart';
import 'package:ruta_placa/core/utils/default_models_utils.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/pico_placa_result.dart';
import 'package:ruta_placa/models/time_range.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/restriction_timer_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/home/form_vehicle_screen.dart';

class MyVehicleCard extends ConsumerWidget {
  final Vehicle vehicle;
  final bool isDefault;

  const MyVehicleCard({
    super.key,
    required this.vehicle,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selectedCity = ref.watch(selectedCityProvider);
    final city = ref.watch(cityByIdProvider(vehicle.cityId));
    final cityRule = ref.watch(
      cityByIdProvider(selectedCity ?? vehicle.cityId),
    );
    final resultPlate = PicoPlacaCalculator.checkPlate(
      cityRule: cityRule ?? cityRuleUtils,
      plate: vehicle.plate,
      vehicleType: vehicle.vehicleType,
      date: DateTime.now(),
      plateOrigin: vehicle.plateOrigin,
    );
    final restriction = cityRule?.restrictionFor(vehicle.vehicleType);
    final morningStart =
        restriction?.morningStart ?? const TimeOfDay(hour: 6, minute: 0);
    final morningEnd =
        restriction?.morningEnd ?? const TimeOfDay(hour: 20, minute: 0);
    final afternoonStart = restriction?.afternoonStart;
    final afternoonEnd = restriction?.afternoonEnd;

    final ranges = restriction?.timeRanges.isNotEmpty == true
        ? restriction!.timeRanges
        : [
            TimeRange(start: morningStart, end: morningEnd),
            if (afternoonStart != null)
              TimeRange(start: afternoonStart, end: afternoonEnd!),
          ];

    // Iniciar el timer con los rangos del vehículo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(restrictionTimerProvider(vehicle.plate).notifier)
          .start(isRestricted: resultPlate.hasRestriction, ranges: ranges);
    });

    final timerState = ref.watch(restrictionTimerProvider(vehicle.plate));

    // Color del borde según el estado del timer
    final borderColor = timerState != null
        ? timerState.borderColor(context)
        : (resultPlate.hasRestriction ? scheme.error : scheme.primary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 🚗 Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: vehicle.getIcon(
                  vehicleType: vehicle.vehicleType,
                  color: borderColor,
                ),
              ),

              const SizedBox(width: 16),

              // 📄 Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.alias,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.plate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      city?.name ?? vehicle.cityId,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusLabel(timerState, resultPlate).toUpperCase(),
                      style: TextStyle(
                        color: borderColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    if (timerState != null &&
                        timerState.status != TimerStatus.free &&
                        timerState.status != TimerStatus.allDay)
                      Text(
                        _timerLabel(timerState),
                        style: TextStyle(
                          color: borderColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    Text(
                      resultPlate.reason.shortMessage.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    if (resultPlate.reason == RestrictionReason.comingSoon)
                      _comingSoonBadge(),
                  ],
                ),
              ),

              // ➡️ Flecha
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          isDefault ? Icons.star : Icons.star_border,
                          size: 30,
                        ),
                        color: isDefault
                            ? theme
                                  .colorScheme
                                  .primary // estrella activa = color primario
                            : theme
                                  .colorScheme
                                  .onSurface // estrella inactiva = gris
                                  .withValues(alpha: 0.4),
                        onPressed: () {
                          // Si ya es default no hacer nada
                          if (isDefault) return;
                          ref
                              .read(vehiclesProvider.notifier)
                              .setDefault(vehicle.id!);
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FormVehicleScreen(vehicle: vehicle),
                              ),
                            );
                          },
                          icon: Icon(Icons.chevron_right, size: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Texto principal según el estado del timer
  String _statusLabel(TimerState? timerState, PicoPlacaResult result) {
    if (timerState == null) {
      return result.hasRestriction ? 'Con pico y placa' : 'Sin pico y placa';
    }
    return switch (timerState.status) {
      TimerStatus.active => 'Con pico y placa',
      TimerStatus.upcoming => 'Pico próximo',
      TimerStatus.allDay => 'Con pico y placa',
      TimerStatus.free => 'Sin pico y placa',
    };
  }

  /// Texto del contador
  String _timerLabel(TimerState s) {
    final h = s.remaining.inHours;
    final m = s.remaining.inMinutes.remainder(60);
    final sec = s.remaining.inSeconds.remainder(60);

    final timeStr = h > 0
        ? '${h}h ${m}m'
        : m > 0
        ? '${m}m ${sec}s'
        : '${sec}s';

    return switch (s.status) {
      TimerStatus.active => 'Termina en $timeStr',
      TimerStatus.upcoming => 'Inicia en $timeStr',
      _ => '',
    };
  }

  Widget _comingSoonBadge() => Container(
    margin: const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.amber.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.amber.shade600, width: 0.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_outlined, size: 12, color: Colors.amber.shade700),
        const SizedBox(width: 4),
        Text(
          'Próximamente',
          style: TextStyle(
            fontSize: 11,
            color: Colors.amber.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
