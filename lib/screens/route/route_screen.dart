import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/core/helpers/app_snackbar.dart';
import 'package:ruta_placa/models/route_city.dart';
import 'package:ruta_placa/providers/route_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/route/add_city_sheet.dart';
import 'package:ruta_placa/screens/route/city_calendar_sheet.dart';
import 'package:ruta_placa/screens/route/empty_route.dart';
import 'package:ruta_placa/screens/route/route_city_card.dart';
import 'package:ruta_placa/widgets/update_icon_widget.dart';

class RouteScreen extends ConsumerStatefulWidget {
  const RouteScreen({super.key});

  @override
  ConsumerState<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends ConsumerState<RouteScreen> {
  bool _cleaning = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rulesProvider.notifier).checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeProvider);
    final rulesState = ref.watch(rulesProvider);
    final vehicle = ref.watch(defaultVehicleProvider);
    final rules = ref.watch(rulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Ruta'),
        actions: [
          if (rules.status == RulesStatus.updateAvailable)
            const UpdateIconWidget(),
          if (routeState.cities.length > 1)
            IconButton(
              icon: _cleaning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cleaning_services_outlined),
              tooltip: 'Limpiar ciudades visitadas',
              onPressed: _cleaning ? null : () => _startCleanup(context),
            ),
          if (routeState.cities.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Borrar toda la ruta',
              onPressed: () => _confirmClearAll(context),
            ),
        ],
      ),
      body: routeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : routeState.cities.isEmpty
          ? EmptyRoute(onAdd: () => _showAddCitySheet(context))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: routeState.cities.length,
                    itemBuilder: (ctx, i) {
                      final city = routeState.cities[i];
                      final cityRule = rulesState.cities
                          .where((c) => c.id == city.cityId)
                          .firstOrNull;

                      return RouteCityCard(
                        city: city,
                        cityRule: cityRule,
                        vehicle: vehicle,
                        isLast: i == routeState.cities.length - 1,
                        onDelete: () => ref
                            .read(routeProvider.notifier)
                            .removeCity(city.id!),
                        onCalendar: () =>
                            _showCalendarSheet(context, city, cityRule),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: routeState.cities.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCitySheet(context),
              label: const Text('Agregar ciudad'),
              icon: const Icon(Icons.add_location_alt_outlined),
            )
          : null,
    );
  }

  Future<void> _startCleanup(BuildContext context) async {
    setState(() => _cleaning = true);
    await ref
        .read(routeProvider.notifier)
        .autoCleanup(delay: const Duration(milliseconds: 800));
    setState(() => _cleaning = false);
    if (context.mounted) {
      AppSnackbar.success(context, 'Ciudades visitadas eliminadas');
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar toda la ruta'),
        content: const Text('¿Estás seguro? Se eliminarán todas las ciudades.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(routeProvider.notifier).clearAll();
    }
  }

  void _showAddCitySheet(BuildContext context) {
    final rules = ref.read(rulesProvider).cities;
    final current = ref.read(routeProvider).cities.map((c) => c.cityId).toSet();

    showModalBottomSheet(
      context: context,
      builder: (_) => AddCitySheet(
        availableCities: rules.where((r) => !current.contains(r.id)).toList(),
        onSelect: (cityRule) {
          ref
              .read(routeProvider.notifier)
              .addCity(
                RouteCity(
                  cityId: cityRule.id,
                  cityName: cityRule.name,
                  cityEmoji: cityRule.emoji,
                  order: 0,
                  addedAt: DateTime.now(),
                ),
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCalendarSheet(
    BuildContext context,
    RouteCity city,
    dynamic cityRule,
  ) {
    if (cityRule == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CityCalendarSheet(
        city: city,
        cityRule: cityRule,
        vehicle: ref.read(defaultVehicleProvider),
      ),
    );
  }
}
