import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _plateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final saved = ref.read(savedPlateProvider);
    if (saved != null) _plateController.text = saved;
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final savedPlate = ref.watch(savedPlateProvider);
    final savedCity = ref.watch(selectedCityProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // ── Sección: Mi vehículo ──────────────────────────
          _SectionHeader(title: 'Mi vehículo'),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Número de placa', style: textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 7,
                      decoration: InputDecoration(
                        hintText: 'Ej: ABC123',
                        counterText: '',
                        prefixIcon: const Icon(Icons.directions_car_outlined),
                        suffixIcon: savedPlate != null
                            ? Icon(
                                Icons.check_circle,
                                color: colorScheme.primary,
                                size: 20,
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        if (val.length >= 5) {
                          ref
                              .read(savedPlateProvider.notifier)
                              .setPlate(val.toUpperCase());
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'El último dígito determina la restricción',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Sección: Ciudad favorita ──────────────────────
          _SectionHeader(title: 'Ciudad favorita'),
          _SettingsCard(
            children: [
              _CitySelector(
                selectedCity: savedCity,
                onChanged: (city) =>
                    ref.read(selectedCityProvider.notifier).state = city,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Sección: Apariencia ───────────────────────────
          _SectionHeader(title: 'Apariencia'),
          _SettingsCard(
            children: [
              _ThemeTile(
                label: 'Seguir sistema',
                subtitle: 'Usa el tema de tu dispositivo',
                icon: Icons.brightness_auto_outlined,
                selected: themeMode == ThemeMode.system,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setMode(ThemeMode.system),
              ),
              const Divider(height: 1),
              _ThemeTile(
                label: 'Modo claro',
                subtitle: 'Fondo blanco',
                icon: Icons.light_mode_outlined,
                selected: themeMode == ThemeMode.light,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setMode(ThemeMode.light),
              ),
              const Divider(height: 1),
              _ThemeTile(
                label: 'Modo oscuro',
                subtitle: 'Fondo negro',
                icon: Icons.dark_mode_outlined,
                selected: themeMode == ThemeMode.dark,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setMode(ThemeMode.dark),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Sección: Publicidad ───────────────────────────
          _SectionHeader(title: 'Publicidad'),
          _SettingsCard(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.star_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text('Quitar anuncios', style: textTheme.titleSmall),
                subtitle: Text(
                  'Disfruta RutaPlaca sin interrupciones',
                  style: textTheme.bodySmall,
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.shade700,
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

          const SizedBox(height: 8),

          // ── Sección: Acerca de ────────────────────────────
          _SectionHeader(title: 'Acerca de'),
          _SettingsCard(
            children: [
              _InfoTile(
                icon: Icons.info_outline,
                label: 'Versión',
                value: '1.0.0',
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.location_city_outlined,
                label: 'Ciudades disponibles',
                value: '6',
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.update_outlined,
                label: 'Reglas actualizadas',
                value: 'Ene 2025',
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
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

          // ── Pie ───────────────────────────────────────────
          Center(
            child: Text(
              'Hecho con ♥ en Colombia',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reportar un error'),
        content: const Text(
          'Si encontraste información incorrecta sobre el pico y placa, '
          'por favor escríbenos a soporte@rutaplaca.app',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: selected
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: selected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: selected
          ? Icon(Icons.check_circle, color: colorScheme.primary, size: 20)
          : const SizedBox(width: 20),
      onTap: onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      leading: Icon(
        icon,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        size: 20,
      ),
      title: Text(label, style: textTheme.bodyMedium),
      trailing: Text(
        value,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _CitySelector extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onChanged;

  const _CitySelector({required this.selectedCity, required this.onChanged});

  static const cities = [
    ('Bogotá', Icons.location_city_outlined),
    ('Medellín', Icons.park_outlined),
    ('Cali', Icons.wb_sunny_outlined),
    ('Pereira', Icons.landscape_outlined),
    ('Manizales', Icons.terrain_outlined),
    ('Barranquilla', Icons.waves_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: cities.map((entry) {
          final (name, icon) = entry;
          final isSelected = selectedCity == name;
          return GestureDetector(
            onTap: () => onChanged(name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.1),
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
