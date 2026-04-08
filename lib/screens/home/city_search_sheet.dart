import 'package:flutter/material.dart';
import 'package:ruta_placa/models/city_rule.dart';

class CitySearchSheet extends StatefulWidget {
  final List<CityRule> cities;

  const CitySearchSheet({super.key, required this.cities});

  @override
  State<CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<CitySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.cities.where((city) {
      return city.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
              height: 350,
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final city = filtered[index];

                  return ListTile(
                    title: Text(city.name),
                    onTap: () {
                      Navigator.pop(context, city.id);
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
