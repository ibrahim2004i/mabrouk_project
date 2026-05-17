import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mabrouk_app/core/storage/local_storage.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(Locale(LocalStorageService.instance.getLocale())) {
    // Sync GetX initially
    Get.updateLocale(state);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await LocalStorageService.instance.saveLocale(locale.languageCode);
    
    // Sync GetX
    Get.updateLocale(state);
  }

  void toggleLocale() {
    if (state.languageCode == 'ar') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('ar'));
    }
  }
}
