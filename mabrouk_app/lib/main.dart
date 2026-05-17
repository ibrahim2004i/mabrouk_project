import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/router/app_router.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mabrouk_app/core/storage/local_storage.dart';

import 'package:sizer/sizer.dart';

import 'package:mabrouk_app/core/localization/app_translations.dart';
import 'package:mabrouk_app/core/localization/locale_provider.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();

  // Initialize GetX translations
  Get.put(AppTranslations());

  runApp(
    const ProviderScope(
      child: MabroukApp(),
    ),
  );
}

class MabroukApp extends ConsumerWidget {
  const MabroukApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp.router(
          title: 'Mabrouk',
          theme: AppTheme.lightTheme,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
          backButtonDispatcher: router.backButtonDispatcher,
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          locale: locale,
          fallbackLocale: const Locale('ar'),
        );
      },
    );
  }
}

/*
    password123
        [1, '0790000000', 'admin@mabrouk.com', $password, 'admin'],
        [2, '0791111111', 'approved_provider@mabrouk.com', $password, 'provider'],
        [4, '0785555555', 'customer1@gmail.com', $password, 'customer'],
* */