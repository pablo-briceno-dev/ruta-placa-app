import 'package:flutter/material.dart';
import 'package:ruta_placa/models/city_rule.dart';

class AddCitySheet extends StatefulWidget {
  final List<CityRule> availableCities;
  final ValueChanged<CityRule> onSelect;

  const AddCitySheet({
    super.key,
    required this.availableCities,
    required this.onSelect,
  });

  @override
  State<AddCitySheet> createState() => _AddCitySheetState();
}

class _AddCitySheetState extends State<AddCitySheet> {
  final _searchController = TextEditingController();
  String query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final screenH = MediaQuery.sizeOf(context).height;
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    // En landscape usar menos altura para que no desborde
    // En portrait usar el comportamiento normal
    final maxHeight = isLandscape
        ? screenH *
              0.85 // 85% del alto en landscape
        : screenH * 0.75; // 75% del alto en portrait
    final filtered = widget.availableCities
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Padding(
      // Respetar el teclado
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Agregar ciudad', style: theme.textTheme.titleMedium),
            ),

            const Divider(height: 1),

            if (widget.availableCities.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Ya agregaste todas las ciudades disponibles'),
              )
            else ...[
              // Buscador
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar ciudad...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true, // más compacto en landscape
                  ),
                  onChanged: (v) => setState(() => query = v),
                ),
              ),

              // Lista — Expanded para ocupar el espacio restante
              // sin desbordarse
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final city = filtered[index];
                    return ListTile(
                      dense: isLandscape, // más compacto en landscape
                      leading: const Icon(Icons.location_city),
                      title: Text(city.name),
                      onTap: () => widget.onSelect(city),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
