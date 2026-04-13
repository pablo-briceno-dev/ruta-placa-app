import 'package:flutter/material.dart';
import 'package:ruta_placa/models/city_rule.dart';

class AddCitySheet extends StatelessWidget {
  final List<CityRule> availableCities;
  final ValueChanged<CityRule> onSelect;

  const AddCitySheet({
    super.key,
    required this.availableCities,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Agregar Ciudad', style: theme.textTheme.titleMedium),
        ),
        const Divider(height: 1),
        if (availableCities.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Ya agregaste todas las ciudades disponibles'),
          ),
        if (availableCities.isNotEmpty)
          ...availableCities.map(
            (city) => ListTile(
              leading: Text(city.emoji, style: const TextStyle(fontSize: 22)),
              title: Text(city.name),
              onTap: () => onSelect(city),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
