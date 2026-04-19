import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/core/utils/default_models_utils.dart';
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
    final plateRegex = RegExp(
      r'^[A-Z]{3}-?\d{2}[A-Z0-9]$',
      caseSensitive: false,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

            if (filtered.isNotEmpty) ...[
              // 🔍 SEARCH
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar vehículo...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() => query = value);
                  },
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
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Placa',
                        border: const OutlineInputBorder(),
                        errorText: plateError,
                      ),
                      onChanged: (value) {
                        final upper = value.toUpperCase();

                        // 🔠 Forzar mayúsculas
                        _plateController.value = _plateController.value
                            .copyWith(
                              text: upper,
                              selection: TextSelection.collapsed(
                                offset: upper.length,
                              ),
                            );

                        // ✅ Validación en tiempo real
                        if (upper.isEmpty) {
                          setState(() => plateError = null);
                          return;
                        }

                        if (!plateRegex.hasMatch(upper)) {
                          setState(
                            () => plateError =
                                'Formato inválido (Ej: ABC123 o ABC-123)',
                          );
                        } else {
                          setState(() => plateError = null);
                        }
                      },
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
                      onChanged: (value) {
                        setState(() => vehicleType = value!);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tipo de vehículo',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    if (cityRule
                            ?.restrictions[vehicleType]
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
                        onChanged: (v) => setState(() => plateOrigin = v!),
                      ),
                    ],

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: () {
                        final plate = _plateController.text.trim();

                        if (plate.isEmpty) return;

                        final newVehicle = Vehicle(
                          plate: plate,
                          alias: 'Consultando: $plate',
                          vehicleTypeIndex: vehicleType.index,
                          cityId: cityRule?.id ?? cityRuleUtils.id,
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
        ),
      ),
    );
  }
}
