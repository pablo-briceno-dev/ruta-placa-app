import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/core/helpers/app_snackbar.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/models/vehicle_type.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/home/city_search_sheet.dart';

class FormVehicleScreen extends ConsumerStatefulWidget {
  final Vehicle? vehicle;

  const FormVehicleScreen({super.key, this.vehicle});

  @override
  ConsumerState<FormVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<FormVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _plateController = TextEditingController();
  final _aliasController = TextEditingController();

  String _selectedCity = 'bogota';
  VehicleType _vehicleType = VehicleType.particular;

  String _getCityName(String cityId, RulesState rulesCities) {
    final city = rulesCities.cities.firstWhere((c) => c.id == cityId);
    return city.name;
  }

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    if (v != null) {
      _plateController.text = v.plate;
      _aliasController.text = v.alias;
      _selectedCity = v.cityId;
      _vehicleType = VehicleType.values[v.vehicleTypeIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    final rulesCities = ref.watch(rulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicle == null ? 'Agregar vehículo' : 'Editar vehículo',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  enabled: widget.vehicle == null,
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una placa';
                    }

                    final regex = RegExp(r'^[A-Z]{3}-?\d{2}[A-Z0-9]$');
                    if (!regex.hasMatch(value)) {
                      return 'Formato inválido (ABC-123 o ABC-12A)';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 🏷️ ALIAS
                TextFormField(
                  controller: _aliasController,
                  decoration: const InputDecoration(
                    labelText: 'Alias (ej: Mi carro)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // 🏙️ CIUDAD
                InkWell(
                  onTap: () async {
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) =>
                          CitySearchSheet(cities: rulesCities.cities),
                    );

                    if (selected != null) {
                      setState(() => _selectedCity = selected);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_getCityName(_selectedCity, rulesCities)),
                  ),
                ),

                const SizedBox(height: 16),

                // 🚘 TIPO DE VEHÍCULO
                DropdownButtonFormField<VehicleType>(
                  initialValue: _vehicleType,
                  items: VehicleType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text('${type.icon} ${type.label}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _vehicleType = value!);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tipo de vehículo',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final vehicle = Vehicle(
                        plate: _plateController.text.trim().toUpperCase(),
                        alias: _aliasController.text.trim().isEmpty
                            ? _plateController.text.toUpperCase()
                            : _aliasController.text.trim(),
                        cityId: _selectedCity,
                        vehicleTypeIndex: _vehicleType.index,
                      );

                      final vehicles = ref.read(vehiclesProvider);

                      if (vehicles.isEmpty) {
                        await ref.read(setDefaultVehicleProvider)(
                          vehicle.plate,
                        );
                      }

                      ref
                          .read(vehiclesProvider.notifier)
                          .addOrUpdateVehicle(vehicle);

                      if (context.mounted) {
                        AppSnackbar.success(context, 'Vehículo guardado');
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ),

                if (widget.vehicle != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Eliminar vehículo'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Eliminar vehículo'),
                            content: const Text('¿Estás seguro?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref
                              .read(vehiclesProvider.notifier)
                              .removeVehicle(widget.vehicle!.plate);

                          if (context.mounted) {
                            AppSnackbar.success(context, 'Vehículo eliminado');
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
