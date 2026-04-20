import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/cities_provider.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/providers/vehicles_provider.dart';
import 'package:ruta_placa/screens/home/form_vehicle_screen.dart';
import 'package:ruta_placa/screens/home/my_vehicles.dart';
import 'package:ruta_placa/screens/home/restricted_digits_row.dart';
import 'package:ruta_placa/widgets/city_selector_button_widget.dart';
import 'package:ruta_placa/widgets/update_icon_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rulesProvider.notifier).checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultVehicle = ref.watch(defaultVehicleProvider);
    final selectedCity = ref.watch(selectedCityProvider);
    final city = ref.watch(
      cityByIdProvider(selectedCity ?? defaultVehicle?.cityId),
    );
    final rules = ref.watch(rulesProvider);
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

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
                  MaterialPageRoute(builder: (_) => const FormVehicleScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: isLandscape
          ? _LandscapeLayout(
              cityId: city?.id ?? 'pasto',
              plate: defaultVehicle?.plate ?? '',
            )
          : _PortraitLayout(
              cityId: city?.id ?? 'pasto',
              plate: defaultVehicle?.plate ?? '',
            ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  final String cityId;
  final String plate;

  const _PortraitLayout({required this.cityId, required this.plate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestrictedDigitsRow(cityId: cityId, plate: plate),
          const Divider(),
          const Text(
            'Mis Vehículos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Expanded(child: MyVehicles()),
        ],
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final String cityId;
  final String plate;

  const _LandscapeLayout({required this.cityId, required this.plate});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda — dígitos restringidos con scroll
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: RestrictedDigitsRow(cityId: cityId, plate: plate),
          ),
        ),

        const VerticalDivider(width: 1),

        // Columna derecha — vehículos
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Vehículos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Expanded(child: MyVehicles()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
