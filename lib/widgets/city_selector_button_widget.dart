import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/widgets/city_selector_sheet_widget.dart';

class CitySelectorButtonWidget extends ConsumerWidget {
  const CitySelectorButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(selectedCityProvider);
    final city = ref
        .watch(rulesProvider)
        .cities
        .firstWhere(
          (c) => c.id == selectedCity,
          orElse: () => CityRule(
            id: 'Ciudad',
            name: 'Ciudad',
            emoji: '',
            restrictions: {},
          ),
        );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const CitySelectorSheetWidget(),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_city, size: 20),
            const SizedBox(width: 6),

            Text(city.name, style: const TextStyle(fontSize: 14)),

            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}
