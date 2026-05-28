import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/localization/language_manager.dart';
import 'features/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load language preference from SharedPreferences
  await LanguageManager.init();

  // Allow google_fonts to fetch Inter & JetBrains Mono from network.
  // Falls back gracefully if offline.
  GoogleFonts.config.allowRuntimeFetching = true;

  // Transparent status bar with light icons (dark UI)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BankApp());
}

class BankApp extends StatelessWidget {
  const BankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageManager.localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Fintech',
          locale: locale,
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const SplashScreen(),
        );
      },
    );
  }
}
