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
    final filtered = widget.availableCities
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Agregar Ciudad', style: theme.textTheme.titleMedium),
        ),
        const Divider(height: 1),
        if (widget.availableCities.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Ya agregaste todas las ciudades disponibles'),
          ),
        if (filtered.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar ciudad...',
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
                final city = filtered[index];

                return ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(city.name),
                  onTap: () => widget.onSelect(city),
                );
              },
            ),
          ),
        ],
        // if (widget.availableCities.isNotEmpty)
        //   ...widget.availableCities.map(
        //     (city) => ListTile(
        //       leading: Text(city.emoji, style: const TextStyle(fontSize: 22)),
        //       title: Text(city.name),
        //       onTap: () => widget.onSelect(city),
        //     ),
        //   ),
        const SizedBox(height: 16),
      ],
    );
  }
}
