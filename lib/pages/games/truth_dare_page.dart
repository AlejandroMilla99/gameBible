import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';

class TruthDarePage extends StatefulWidget {
  final String title;
  const TruthDarePage({super.key, required this.title});

  @override
  State<TruthDarePage> createState() => _TruthDarePageState();
}

class _TruthDarePageState extends State<TruthDarePage> {
  final List<String> truths = [
    "¿Cuál ha sido tu mayor vergüenza?",
    "¿Has mentido a un amigo recientemente?",
    "¿Quién es tu crush secreto?",
    "¿Cuál ha sido la peor cita que has tenido?",
  ];

  final List<String> dares = [
    "Imita a alguien del grupo durante 1 minuto.",
    "Haz 10 flexiones ahora mismo.",
    "Baila sin música por 30 segundos.",
    "Habla con acento raro hasta tu próximo turno.",
  ];

  String? currentChallenge;

  final _random = Random();

  void _pickTruth() {
    setState(() {
      currentChallenge = truths[_random.nextInt(truths.length)];
    });
  }

  void _pickDare() {
    setState(() {
      currentChallenge = dares[_random.nextInt(dares.length)];
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
                child: currentChallenge == null
                    ? const Text(
                        "Elige Verdad o Reto para comenzar",
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
                          currentChallenge!,
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
                  onPressed: _pickTruth,
                  icon: const Icon(Icons.question_answer, color: Colors.blue),
                  tooltip: "Verdad",
                ),
                IconButton(
                  iconSize: 64,
                  onPressed: _pickDare,
                  icon: const Icon(Icons.local_fire_department, color: Colors.red),
                  tooltip: "Reto",
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
