import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/core/utils/default_models_utils.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/plate_origin.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';

class VehiclesSelectorSheet extends ConsumerStatefulWidget {
  final List<Vehicle> vehicles;

  const VehiclesSelectorSheet({super.key, required this.vehicles});

  @override
  ConsumerState<VehiclesSelectorSheet> createState() =>
      _VehiclesSelectorSheetState();
}

class _VehiclesSelectorSheetState extends ConsumerState<VehiclesSelectorSheet> {
  final _searchController = TextEditingController();
  String query = '';
  final _plateController = TextEditingController();
  VehicleType vehicleType = VehicleType.particular;
  String? plateError;
  PlateOrigin plateOrigin = PlateOrigin.any;
  static final plateRegex = RegExp(
    r'^[A-Z]{3}-?\d{2}[A-Z0-9]$',
    caseSensitive: false,
  );

  void onSearchVehicle(String value) => setState(() => query = value);

  void onPlateVehicle(String value) {
    final upper = value.toUpperCase();

    // 🔠 Forzar mayúsculas
    _plateController.value = _plateController.value.copyWith(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );

    // ✅ Validación en tiempo real
    if (upper.isEmpty) {
      setState(() => plateError = null);
      return;
    }

    if (!plateRegex.hasMatch(upper)) {
      setState(() => plateError = 'Formato inválido (Ej: ABC123 o ABC-123)');
    } else {
      setState(() => plateError = null);
    }
  }

  void onVehicleTypeChanged(VehicleType? value) =>
      setState(() => vehicleType = value!);

  void onPlateOriginChanged(PlateOrigin? value) =>
      setState(() => plateOrigin = value!);

  @override
  Widget build(BuildContext context) {
    final filtered = widget.vehicles
        .where(
          (v) =>
              v.alias.toLowerCase().contains(query.toLowerCase()) ||
              v.plate.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    final selectedCity = ref.watch(selectedCityProvider);
    final cityRule = ref.watch(cityByIdProvider(selectedCity));
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: isLandscape
          ? _LandscapeLayout(
              searchController: _searchController,
              plateController: _plateController,
              vehicleType: vehicleType,
              plateOrigin: plateOrigin,
              filtered: filtered,
              onSearchVehicle: onSearchVehicle,
              cityRule: cityRule ?? cityRuleUtils,
              onPlateVehicle: onPlateVehicle,
              onVehicleTypeChanged: onVehicleTypeChanged,
              onPlateOriginChanged: onPlateOriginChanged,
            )
          : _PortraitLayout(
              searchController: _searchController,
              plateController: _plateController,
              vehicleType: vehicleType,
              plateOrigin: plateOrigin,
              filtered: filtered,
              onSearchVehicle: onSearchVehicle,
              cityRule: cityRule ?? cityRuleUtils,
              onPlateVehicle: onPlateVehicle,
              onVehicleTypeChanged: onVehicleTypeChanged,
              onPlateOriginChanged: onPlateOriginChanged,
            ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  final TextEditingController searchController;
  final String query = '';
  final TextEditingController plateController;
  final VehicleType vehicleType;
  final String? plateError;
  final PlateOrigin plateOrigin;
  final List<Vehicle> filtered;
  final CityRule cityRule;
  final Function(String) onSearchVehicle;
  final Function(String) onPlateVehicle;
  final Function(VehicleType?) onVehicleTypeChanged;
  final Function(PlateOrigin?) onPlateOriginChanged;

  const _PortraitLayout({
    required this.searchController,
    required this.plateController,
    required this.vehicleType,
    required this.plateOrigin,
    required this.filtered,
    required this.onSearchVehicle,
    required this.cityRule,
    required this.onPlateVehicle,
    required this.onVehicleTypeChanged,
    required this.onPlateOriginChanged,
    // ignore: unused_element_parameter
    this.plateError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),

        if (filtered.isNotEmpty) ...[
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar vehículo...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchVehicle,
            ),
          ),

          // 📋 LISTA
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                final vehicle = filtered[index];

                return ListTile(
                  leading: vehicle.getIcon(vehicleType: vehicle.vehicleType),
                  title: Text(vehicle.alias),
                  subtitle: Text(vehicle.plate),
                  onTap: () {
                    Navigator.pop(context, vehicle);
                  },
                );
              },
            ),
          ),
        ],

        if (query.isEmpty) ...[
          const Divider(),
          // ➕ FORMULARIO (siempre visible o solo si vacío)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Consultar vehículo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: plateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Placa',
                    border: const OutlineInputBorder(),
                    errorText: plateError,
                  ),
                  onChanged: onPlateVehicle,
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<VehicleType>(
                  initialValue: vehicleType,
                  items: VehicleType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text('${type.icon} ${type.label}'),
                    );
                  }).toList(),
                  onChanged: onVehicleTypeChanged,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de vehículo',
                    border: OutlineInputBorder(),
                  ),
                ),

                if (cityRule
                        .restrictions[vehicleType]
                        ?.timeRangesByOrigin
                        .isNotEmpty ==
                    true) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PlateOrigin>(
                    initialValue: plateOrigin,
                    decoration: const InputDecoration(
                      labelText: 'Origen de la placa',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: PlateOrigin.any,
                        child: Text('Ninguna'),
                      ),
                      DropdownMenuItem(
                        value: PlateOrigin.metropolitan,
                        child: Text('Área metropolitana o de esta ciudad'),
                      ),
                      DropdownMenuItem(
                        value: PlateOrigin.nationalOrForeign,
                        child: Text(
                          'Nacional - extranjera - fuera de esta ciudad',
                        ),
                      ),
                    ],
                    onChanged: onPlateOriginChanged,
                  ),
                ],

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () {
                    final plate = plateController.text.trim();

                    if (plate.isEmpty) return;

                    final newVehicle = Vehicle(
                      plate: plate,
                      alias: 'Consultando: $plate',
                      vehicleTypeIndex: vehicleType.index,
                      cityId: cityRule.id,
                    );

                    Navigator.pop(context, newVehicle);
                  },
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Consultar'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final TextEditingController searchController;
  final String query = '';
  final TextEditingController plateController;
  final VehicleType vehicleType;
  final String? plateError;
  final PlateOrigin plateOrigin;
  final List<Vehicle> filtered;
  final CityRule cityRule;
  final Function(String) onSearchVehicle;
  final Function(String) onPlateVehicle;
  final Function(VehicleType?) onVehicleTypeChanged;
  final Function(PlateOrigin?) onPlateOriginChanged;

  const _LandscapeLayout({
    required this.searchController,
    required this.plateController,
    required this.vehicleType,
    required this.plateOrigin,
    required this.filtered,
    required this.cityRule,
    required this.onSearchVehicle,
    required this.onPlateVehicle,
    required this.onVehicleTypeChanged,
    required this.onPlateOriginChanged,
    // ignore: unused_element_parameter
    this.plateError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda — dígitos restringidos con scroll
        if (filtered.isNotEmpty) ...[
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // 🔍 SEARCH
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar vehículo...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: onSearchVehicle,
                    ),
                  ),

                  // 📋 LISTA
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, index) {
                        final vehicle = filtered[index];

                        return ListTile(
                          leading: vehicle.getIcon(
                            vehicleType: vehicle.vehicleType,
                          ),
                          title: Text(vehicle.alias),
                          subtitle: Text(vehicle.plate),
                          onTap: () {
                            Navigator.pop(context, vehicle);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
        ],

        // Columna derecha — vehículos
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Consultar vehículo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: plateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Placa',
                    border: const OutlineInputBorder(),
                    errorText: plateError,
                  ),
                  onChanged: onPlateVehicle,
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<VehicleType>(
                  initialValue: vehicleType,
                  items: VehicleType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text('${type.icon} ${type.label}'),
                    );
                  }).toList(),
                  onChanged: onVehicleTypeChanged,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de vehículo',
                    border: OutlineInputBorder(),
                  ),
                ),

                if (cityRule
                        .restrictions[vehicleType]
                        ?.timeRangesByOrigin
                        .isNotEmpty ==
                    true) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PlateOrigin>(
                    initialValue: plateOrigin,
                    decoration: const InputDecoration(
                      labelText: 'Origen de la placa',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: PlateOrigin.any,
                        child: Text('Ninguna'),
                      ),
                      DropdownMenuItem(
                        value: PlateOrigin.metropolitan,
                        child: Text('Área metropolitana o de esta ciudad'),
                      ),
                      DropdownMenuItem(
                        value: PlateOrigin.nationalOrForeign,
                        child: Text(
                          'Nacional - extranjera - fuera de esta ciudad',
                        ),
                      ),
                    ],
                    onChanged: onPlateOriginChanged,
                  ),
                ],

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () {
                    final plate = plateController.text.trim();

                    if (plate.isEmpty) return;

                    final newVehicle = Vehicle(
                      plate: plate,
                      alias: 'Consultando: $plate',
                      vehicleTypeIndex: vehicleType.index,
                      cityId: cityRule.id,
                    );

                    Navigator.pop(context, newVehicle);
                  },
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Consultar'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
