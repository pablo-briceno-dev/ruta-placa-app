import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';

class CitySelectorSheetWidget extends ConsumerStatefulWidget {
  const CitySelectorSheetWidget({super.key});

  @override
  ConsumerState<CitySelectorSheetWidget> createState() =>
      _CitySelectorSheetWidgetState();
}

class _CitySelectorSheetWidgetState
    extends ConsumerState<CitySelectorSheetWidget> {
  final _searchController = TextEditingController();

  String query = '';

  @override
  Widget build(BuildContext context) {
    final cities = ref.watch(rulesProvider).cities;
    final filtered = cities
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
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
                    title: Text('${city.emoji} ${city.name}'),
                    onTap: () async {
                      await ref
                          .read(selectedCityProvider.notifier)
                          .setCity(city.id);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
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
