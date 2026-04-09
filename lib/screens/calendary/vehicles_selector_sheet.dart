import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/models/vehicle.dart';

class VehiclesSelectorSheet extends ConsumerStatefulWidget {
  final List<Vehicle> vehicles;

  const VehiclesSelectorSheet({super.key, required this.vehicles});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VehiclesSelectorSheetState();
}

class _VehiclesSelectorSheetState extends ConsumerState<VehiclesSelectorSheet> {
  final _searchController = TextEditingController();
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.vehicles
        .where(
          (v) =>
              v.alias.toLowerCase().contains(query.toLowerCase()) ||
              v.plate.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

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
                    leading: const Icon(Icons.directions_car),
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
    );
  }
}
