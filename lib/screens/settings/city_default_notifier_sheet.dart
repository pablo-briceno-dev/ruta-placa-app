import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/data/key_preferences.dart';
import 'package:ruta_placa/providers/notification_settings_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/shared_preferences_provider.dart';

class CityDefaultNotifierSheet extends ConsumerStatefulWidget {
  const CityDefaultNotifierSheet({super.key});

  @override
  ConsumerState<CityDefaultNotifierSheet> createState() =>
      _CityDefaultNotifierSheetState();
}

class _CityDefaultNotifierSheetState
    extends ConsumerState<CityDefaultNotifierSheet> {
  final _searchController = TextEditingController();

  String query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final cities = ref.watch(rulesProvider).cities;
    final filtered = cities
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final screenH = MediaQuery.sizeOf(context).height;
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final maxHeight = isLandscape
        ? screenH *
              0.85 // 85% del alto en landscape
        : screenH * 0.45; // 75% del alto en portrait

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

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
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final city = filtered[index];

                  return ListTile(
                    dense: isLandscape,
                    leading: const Icon(Icons.location_city),
                    title: Text(city.name, overflow: TextOverflow.ellipsis),
                    onTap: () async {
                      await ref
                          .read(preferencesProvider.notifier)
                          .setString(selectedCityNotify, city.id);
                      await ref
                          .read(notificationSettingsProvider.notifier)
                          .setCityDefault(city.id);

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
