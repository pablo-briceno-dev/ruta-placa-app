import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ruta_placa/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación solo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializamos AdMob
  await MobileAds.instance.initialize();
  // AdmobService.instance.loadInterstitial();

  runApp(const ProviderScope(child: RutaPlacaApp()));
}
