import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ruta_placa/config/secrets.dart';

class AdmobService {
  AdmobService._();
  static final AdmobService instance = AdmobService._();

  // ────────────────────────────────────────────
  // IDs — TEST en debug, REALES en release
  // ────────────────────────────────────────────
  static bool get _isTest =>
      const bool.fromEnvironment('dart.vm.product') == false;

  String get bannerAdUnitId {
    if (_isTest) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'   // test Android
          : 'ca-app-pub-3940256099942544/2934735716';  // test iOS
    }
    return Platform.isAndroid
        ? admobBannerId   // ← reemplaza
        : 'ca-app-pub-TU_ID/TU_BANNER_IOS';      // ← reemplaza
  }

  String get interstitialAdUnitId {
    if (_isTest) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return Platform.isAndroid
        ? admobInterstitialId
        : 'ca-app-pub-TU_ID/TU_INTER_IOS';
  }

  // ────────────────────────────────────────────
  // Interstitial — se precarga para mostrarlo al instante
  // ────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _interstitialReady = false;

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialReady = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              _interstitialReady = false;
              loadInterstitial(); // precarga el siguiente
            },
            onAdFailedToShowFullScreenContent: (_, __) {
              _interstitialReady = false;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialReady = false;
          // Reintentar en 30 seg para no saturar
          Future.delayed(
            const Duration(seconds: 30),
            loadInterstitial,
          );
        },
      ),
    );
  }

  /// Llama esto cuando el usuario genera una ruta
  void showInterstitialIfReady() {
    if (_interstitialReady && _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
