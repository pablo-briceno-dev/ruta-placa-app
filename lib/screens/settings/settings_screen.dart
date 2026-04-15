import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/settings_provider.dart';
import 'package:ruta_placa/providers/theme_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/settings/info_tile.dart';
import 'package:ruta_placa/screens/settings/section_card.dart';
import 'package:ruta_placa/screens/settings/section_header.dart';
import 'package:ruta_placa/screens/settings/test_notificacion.dart';
import 'package:ruta_placa/screens/settings/theme_tile.dart';
import 'package:ruta_placa/screens/settings/vehicles_switch_list_sheet.dart';
import 'package:ruta_placa/services/notification_service.dart';
import 'package:ruta_placa/services/rules_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final notifState = ref.watch(notificationSettingsProvider);
    final vehicles = ref.watch(vehiclesProvider).vehicles;
    final cities = ref.watch(rulesProvider).cities;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // General --------------------
          SectionHeader('General'),
          SectionCard(
            children: [
              ThemeTile(
                label: 'Seguir sistema',
                subtitle: 'Usa el tema del dispositivo',
                icon: Icons.brightness_auto_outlined,
                selected: themeMode == ThemeMode.system,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setMode(ThemeMode.system),
              ),
              const Divider(height: 1),
              ThemeTile(
                label: 'Modo claro',
                subtitle: 'Fondo blanco',
                icon: Icons.light_mode_outlined,
                selected: themeMode == ThemeMode.light,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setMode(ThemeMode.light),
              ),
              const Divider(height: 1),
              ThemeTile(
                label: 'Modo oscuro',
                subtitle: 'Fondo negro',
                icon: Icons.light_mode_outlined,
                selected: themeMode == ThemeMode.dark,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setMode(ThemeMode.dark),
              ),
            ],
          ),
          // Notificaciones --------------------
          SectionHeader('Notificaciones'),
          SectionCard(
            children: [
              // Master switch
              SwitchListTile(
                value: notifState.notificationsEnabled,
                onChanged: (v) => _toggleNotifications(v),
                secondary: _iconBox(
                  Icons.notifications_outlined,
                  colorScheme.primary,
                ),
                title: Text(
                  'Activar notificaciones',
                  style: textTheme.titleSmall,
                ),
                subtitle: Text(
                  'Recibe avisos cuando tengas pico y placa',
                  style: textTheme.bodySmall,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              if (notifState.notificationsEnabled) ...[
                if (kDebugMode) ...[
                  // Test notification ------------------------------
                  const Divider(height: 1),
                  TestNotificacion(),
                  // ------------------------------------------------
                ],
                const Divider(height: 1),
                // Dia anterior
                SwitchListTile(
                  value: notifState.dayBeforeEnabled,
                  onChanged: (value) => ref
                      .read(notificationSettingsProvider.notifier)
                      .setDayBefore(value),
                  secondary: _iconBox(
                    Icons.wb_twilight_outlined,
                    Colors.indigo,
                  ),
                  title: Text('Día anterior', style: textTheme.bodySmall),
                  subtitle: Text(
                    'Aviso al día anterior al pico y placa',
                    style: textTheme.bodySmall,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
                if (notifState.dayBeforeEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    leading: _iconBox(
                      Icons.access_time_outlined,
                      Colors.indigo.withValues(alpha: 0.6),
                    ),
                    title: Text('Hora del aviso', style: textTheme.bodyMedium),
                    subtitle: Text(
                      'Se enviará a esta hora',
                      style: textTheme.bodySmall,
                    ),
                    trailing: GestureDetector(
                      onTap: () => _pickTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          notifState.dayBeforeTimeFormatted,
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const Divider(height: 1),

                // Mismo día ----------------------
                SwitchListTile(
                  value: notifState.sameDayEnabled,
                  onChanged: (value) => ref
                      .read(notificationSettingsProvider.notifier)
                      .setSameDay(value),
                  secondary: _iconBox(Icons.alarm_outlined, Colors.orange),
                  title: Text('Mismo día', style: textTheme.titleSmall),
                  subtitle: Text(
                    '1 hora antes del inicio del pico y placa',
                    style: textTheme.bodySmall,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),

                const Divider(height: 1),
                // Por Vehículo ---------------------------------
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _iconBox(
                      Icons.add_alert_outlined,
                      colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    'Alertas por Vehículo',
                    style: textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    vehicles.isNotEmpty
                        ? 'Activa alarmas por cada vehículo'
                        : 'Agrega vehículos en la pantalla de Inicio',
                    style: textTheme.bodySmall,
                  ),
                  trailing: vehicles.isNotEmpty
                      ? Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          size: 18,
                        )
                      : null,
                  onTap: vehicles.isNotEmpty
                      ? () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const VehiclesSwitchListSheet(),
                          );
                        }
                      : null,
                ),
              ],
            ],
          ),
          // Donaciones -----------------------
          SectionHeader('Apoyar RutaPlaca'),
          SectionCard(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                leading: _iconBox(Icons.favorite_outline, Colors.pink),
                title: Text(
                  'Donar voluntariamente',
                  style: textTheme.titleSmall,
                ),
                subtitle: Text(
                  'Si la app te es útil, considera apoyar su desarrollo',
                  style: textTheme.bodySmall,
                ),
                onTap: () => _showDonationInfo(context),
              ),

              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                leading: _iconBox(Icons.star_outline, colorScheme.primary),
                title: Text('Quitar anuncios', style: textTheme.titleSmall),
                subtitle: Text(
                  'Compra única o suscripción para disfrutar sin publicidad',
                  style: textTheme.bodySmall,
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.shade600,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Próximamente',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Acerca de -----------------------
          SectionHeader('Acerca de'),
          SectionCard(
            children: [
              InfoTile(
                icon: Icons.info_outline,
                label: 'Versión',
                value: _version.isEmpty ? '...' : _version,
              ),
              const Divider(height: 1),
              InfoTile(
                icon: Icons.location_city_outlined,
                label: 'Ciudades disponibles',
                value: cities.length.toString(),
              ),
              const Divider(height: 1),
              InfoTile(
                icon: Icons.update_outlined,
                label: 'Reglas actualizadas (Pico y Placa)',
                value:
                    RulesService.instance.cachedLastCheck ??
                    'Sin datos disponibles',
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Icon(
                  Icons.refresh_outlined,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                title: Text('Actualizar reglas', style: textTheme.bodyMedium),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 18,
                ),
                onTap: () => _refreshRules(context),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Icon(
                  Icons.bug_report_outlined,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                title: Text('Reportar un error', style: textTheme.bodyMedium),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 18,
                ),
                onTap: () => _showReportDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Hecho con ❤️ en Colombia',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────
  Widget _iconBox(IconData icon, Color color) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: color, size: 20),
  );

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Debes permitir las notificaciones en Ajustes del sistema',
            ),
          ),
        );
        return;
      }
    }
    await ref.read(notificationSettingsProvider.notifier).setEnabled(value);
  }

  Future<void> _pickTime(BuildContext context) async {
    final current = ref.read(notificationSettingsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: current.dayBeforeHour,
        minute: current.dayBeforeMinute,
      ),
      helpText: 'Hora del aviso del día anterior',
    );
    if (picked != null) {
      await ref
          .read(notificationSettingsProvider.notifier)
          .setDayBeforeTime(picked.hour, picked.minute);
    }
  }

  Future<void> _refreshRules(BuildContext context) async {
    // Llama al RulesNotifier que ya definimos antes
    ref.read(rulesProvider.notifier).refresh();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Actualizando reglas...')));
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reportar un error'),
        content: const Text(
          'Si encontraste información incorrecta sobre el pico y placa, '
          'escríbenos a pablo.briceno.dev@gmail.com con el asunto RutaPlaca',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDonationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Donación voluntaria'),
        content: Text(
          'Si esta app te ha sido útil, puedes apoyar su desarrollo con una donación voluntaria. Cada aporte ayuda a seguir mejorándola.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await launchUrl(
                Uri.parse('https://www.paypal.com/paypalme/pablobricenodev/1'),
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.volunteer_activism_outlined, size: 16),
            label: const Text('PayPal'),
          ),
        ],
      ),
    );
  }
}
