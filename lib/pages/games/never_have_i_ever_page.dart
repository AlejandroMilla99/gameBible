import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';

class NeverHaveIEverPage extends StatefulWidget {
  final String title;
  const NeverHaveIEverPage({super.key, required this.title});

  @override
  State<NeverHaveIEverPage> createState() => _NeverHaveIEverPageState();
}

class _NeverHaveIEverPageState extends State<NeverHaveIEverPage> {
  final List<String> normal = [
    "Nunca he copiado en un examen.",
    "Nunca he cantado en la ducha.",
    "Nunca me he dormido en el transporte público.",
    "Nunca he perdido un vuelo.",
  ];

  final List<String> plus18 = [
    "Nunca he tenido una cita a ciegas.",
    "Nunca he enviado un mensaje atrevido.",
    "Nunca he besado a alguien en público.",
    "Nunca he mentido sobre con quién estaba.",
  ];

  String? currentStatement;
  final _random = Random();

  void _pickNormal() {
    setState(() {
      currentStatement = normal[_random.nextInt(normal.length)];
    });
  }

  void _pick18() {
    setState(() {
      currentStatement = plus18[_random.nextInt(plus18.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: currentStatement == null
                    ? const Text(
                        "Elige Normal o +18 para comenzar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          currentStatement!,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 64,
                  onPressed: _pickNormal,
                  icon: const Icon(Icons.sentiment_satisfied, color: Colors.green),
                  tooltip: "Normal",
                ),
                IconButton(
                  iconSize: 64,
                  onPressed: _pick18,
                  icon: const Icon(Icons.explicit, color: Colors.purple),
                  tooltip: "+18",
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
