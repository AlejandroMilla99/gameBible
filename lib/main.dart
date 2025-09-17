import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/splash_page.dart';
import 'constants/app_colors.dart';
import 'package:gamebible/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('locale') ?? 'es';

  runApp(JuegosConAmigosApp(initialLocale: Locale(savedLocale)));
}

class JuegosConAmigosApp extends StatefulWidget {
  final Locale initialLocale;
  const JuegosConAmigosApp({super.key, required this.initialLocale});

  @override
  State<JuegosConAmigosApp> createState() => _JuegosConAmigosAppState();

  /// Helper para acceder desde cualquier parte y cambiar el idioma
  static _JuegosConAmigosAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_JuegosConAmigosAppState>();
}

class _JuegosConAmigosAppState extends State<JuegosConAmigosApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juegos con Amigos',
      locale: _locale,
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
