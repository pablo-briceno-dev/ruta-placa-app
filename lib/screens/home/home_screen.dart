import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/home/add_vehicle_screen.dart';
import 'package:ruta_placa/screens/home/my_vehicles.dart';
import 'package:ruta_placa/screens/home/restricted_digits_row.dart';
import 'package:ruta_placa/widgets/city_selector_button_widget.dart';
import 'package:ruta_placa/widgets/update_icon_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_checked) {
        ref.read(rulesProvider.notifier).checkForUpdates();
        _checked = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultVehicle = ref.watch(defaultVehicleProvider);
    final selectedCity = ref.watch(selectedCityProvider);
    final city = ref.watch(
      cityByIdProvider(selectedCity ?? defaultVehicle?.cityId ?? 'bogota'),
    );
    final rules = ref.watch(rulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RutaPlaca'),
        actions: [
          if (rules.status == RulesStatus.updateAvailable)
            const UpdateIconWidget(),
          CitySelectorButtonWidget(),
        ],
      ),
      floatingActionButton: defaultVehicle != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          // !Banner Ad (parte superior o inferior de la pantalla)
          // const AdBannerWidget(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RestrictedDigitsRow(
                    cityId: city?.id ?? 'bogota',
                    plate: defaultVehicle?.plate ?? '',
                  ),
                  const Divider(),
                  const Text(
                    'Mis Vehículos',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  MyVehicles(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
