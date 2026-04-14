import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;
import 'package:ruta_placa/core/router.dart';
import 'package:ruta_placa/core/theme.dart';
import 'package:ruta_placa/providers/shared_preferences_provider.dart';
import 'package:ruta_placa/providers/theme_provider.dart';
import 'package:ruta_placa/services/background_service.dart';
import 'package:ruta_placa/services/database_service.dart';
import 'package:ruta_placa/services/notification_service.dart';
import 'package:ruta_placa/services/rules_service.dart';
import 'package:ruta_placa/services/widget_service.dart';
import 'package:ruta_placa/widgets/global_listeners.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RulesService.instance.init();

  final prefs = await SharedPreferences.getInstance();

  await initializeDateFormatting('es_ES', null);

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'widgetUpdate',
    taskName,
    frequency: const Duration(minutes: 30),
    constraints: Constraints(networkType: NetworkType.notRequired),
  );

  await WidgetService.instance.init();

  // SQLite — precalentar la conexión
  await DatabaseService.instance.db;
  await NotificationService.instance.init();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: GlobalListeners(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'RutaPlaca',
      debugShowCheckedModeBanner: false,
      theme: RutaPlacaTheme.light,
      darkTheme: RutaPlacaTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'CO')],
    );
  }
}
