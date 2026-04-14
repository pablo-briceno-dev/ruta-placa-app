import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/services/city_rules_reader.dart';
import 'package:ruta_placa/services/notification_service.dart';

class TestNotificacion extends ConsumerStatefulWidget {
  const TestNotificacion({super.key});

  @override
  ConsumerState<TestNotificacion> createState() => _TestNotificacionState();
}

class _TestNotificacionState extends ConsumerState<TestNotificacion> {
  bool _testLoading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.send_outlined, color: Colors.blue, size: 20),
      ),
      title: Text('Enviar notificación de prueba', style: textTheme.titleSmall),
      subtitle: Text(
        'Verifica que las alertas funcionan correctamente',
        style: textTheme.bodySmall,
      ),
      trailing: _testLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 18,
            ),
      onTap: _testLoading ? null : () => _sendTestNotification(context),
    );
  }

  Future<void> _sendTestNotification(BuildContext context) async {
    final vehicle = ref.read(defaultVehicleProvider);

    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Agrega un vehículo primero para probar la notificación',
          ),
        ),
      );
      return;
    }

    setState(() => _testLoading = true);

    // Verificar permiso antes de intentar
    final hasPermission = await NotificationService.instance.hasPermission();
    if (!hasPermission) {
      setState(() => _testLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Activa el permiso de notificaciones en Ajustes del sistema',
            ),
            action: SnackBarAction(
              label: 'Abrir',
              onPressed: openAppSettings, // de permission_handler
            ),
          ),
        );
      }
      return;
    }

    final rules = ref.read(rulesProvider);
    final cityRule = CityRulesReader(rules.cities).getCity(vehicle.cityId);

    await NotificationService.instance.sendTestNotification(
      vehicle: vehicle,
      cityRule: cityRule,
    );

    setState(() => _testLoading = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Notificación enviada para ${vehicle.alias}'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
