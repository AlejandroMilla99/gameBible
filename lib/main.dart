import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const JuegosConAmigosApp());
}

class JuegosConAmigosApp extends StatelessWidget {
  const JuegosConAmigosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juegos con Amigos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
