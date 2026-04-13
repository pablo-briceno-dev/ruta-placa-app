import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/logic/pico_placa_calculator.dart';
import 'package:ruta_placa/models/city_rule.dart';
import 'package:ruta_placa/models/route_city.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:ruta_placa/screens/route/calendar_cell.dart';
import 'package:ruta_placa/screens/route/legend_item.dart';

class CityCalendarSheet extends ConsumerStatefulWidget {
  final RouteCity city;
  final CityRule? cityRule;
  final Vehicle? vehicle;

  const CityCalendarSheet({
    super.key,
    required this.city,
    this.cityRule,
    this.vehicle,
  });

  @override
  ConsumerState<CityCalendarSheet> createState() => _CityCalendarSheetState();
}

class _CityCalendarSheetState extends ConsumerState<CityCalendarSheet> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  widget.city.cityEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(widget.city.cityName, style: theme.textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(
                    () => _month = DateTime(_month.year, _month.month - 1),
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_monthName(_month.month)} ${_month.year}',
                  style: theme.textTheme.bodyMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(
                    () => _month = DateTime(_month.year, _month.month + 1),
                  ),
                ),
              ],
            ),
          ),

          // Días de semana
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 4),

          // Grilla del calendario
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: firstWeekday - 1 + daysInMonth,
                itemBuilder: (ctx, index) {
                  if (index < firstWeekday - 1) {
                    return const SizedBox.shrink();
                  }
                  final day = index - (firstWeekday - 1) + 1;
                  final date = DateTime(_month.year, _month.month, day);
                  final isToday = DateUtils.isSameDay(date, DateTime.now());

                  if (widget.vehicle == null || widget.cityRule == null) {
                    return CalendarCell(day: day, isToday: isToday);
                  }

                  final result = PicoPlacaCalculator.checkPlate(
                    cityRule: widget.cityRule!,
                    plate: widget.vehicle!.plate,
                    vehicleType: widget.vehicle!.vehicleType,
                    date: date,
                  );

                  return CalendarCell(
                    day: day,
                    isToday: isToday,
                    hasRestriction: result.hasRestriction,
                    appliesToAll: result.appliesToAll,
                    restrictedPlates: result.restrictedPlates,
                  );
                },
              ),
            ),
          ),

          // Leyenda
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendItem(color: Colors.green, label: 'Libre'),
                const SizedBox(width: 16),
                LegendItem(color: colorScheme.error, label: 'Restricción'),
                const SizedBox(width: 16),
                LegendItem(color: Colors.orange, label: 'Todos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return names[month - 1];
  }
}
