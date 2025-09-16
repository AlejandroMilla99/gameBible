import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'constants/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gamebible/l10n/app_localizations.dart';

void main() {
  runApp(const JuegosConAmigosApp());
}

class JuegosConAmigosApp extends StatelessWidget {
  const JuegosConAmigosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juegos con Amigos',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // Inglés
        Locale('es'), // Español
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
