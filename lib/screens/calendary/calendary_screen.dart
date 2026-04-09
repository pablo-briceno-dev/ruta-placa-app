import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/screens/calendary/vehicles_selector_button.dart';
import 'package:ruta_placa/widgets/city_selector_button_widget.dart';
import 'package:ruta_placa/widgets/update_icon_widget.dart';

class CalendaryScreen extends ConsumerStatefulWidget {
  const CalendaryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CalendaryScreenState();
}

class _CalendaryScreenState extends ConsumerState<CalendaryScreen> {
  Vehicle? selectedVehicle;
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
    final rules = ref.watch(rulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          if (rules.status == RulesStatus.updateAvailable)
            const UpdateIconWidget(),
          CitySelectorButtonWidget(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: VehiclesSelectorButton(
                selected: selectedVehicle,
                onSelected: (vehicle) {
                  setState(() => selectedVehicle = vehicle);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
