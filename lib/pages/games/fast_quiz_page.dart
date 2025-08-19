import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import '../../components/stopwatch_timer.dart';

class FastQuizPage extends StatefulWidget {
  final String title;
  const FastQuizPage({super.key, required this.title});

  @override
  State<FastQuizPage> createState() => _FastQuizPageState();
}

class _FastQuizPageState extends State<FastQuizPage> {
  final List<Map<String, dynamic>> questions = [
    {
      "question": "¿Cuál es la capital de Francia?",
      "options": ["París", "Londres", "Berlín", "Roma"],
      "answer": "París"
    },
    {
      "question": "¿Cuál es el planeta más cercano al sol?",
      "options": ["Mercurio", "Venus", "Marte", "Júpiter"],
      "answer": "Mercurio"
    },
    {
      "question": "¿Quién escribió 'Cien años de soledad'?",
      "options": [
        "Gabriel García Márquez",
        "Pablo Neruda",
        "Isabel Allende",
        "Mario Vargas Llosa"
      ],
      "answer": "Gabriel García Márquez"
    },
  ];

  Map<String, dynamic>? currentQuestion;
  String? selectedAnswer;
  bool answered = false;
  bool showFeedback = false;
  final _random = Random();

  int correctAnswers = 0;

  void _pickQuestion() {
    setState(() {
      currentQuestion = questions[_random.nextInt(questions.length)];
      selectedAnswer = null;
      answered = false;
      showFeedback = false;
    });
  }

  void _selectAnswer(String answer) {
    if (!answered) {
      final correct = currentQuestion!["answer"];
      setState(() {
        selectedAnswer = answer;
        answered = true;
        // Solo mostramos feedback si es correcto
        showFeedback = answer == correct;
        if (answer == correct) correctAnswers++;
      });

      if (answer == correct) {
        // Ocultar feedback automáticamente después de 2 segundos solo si es correcto
        Timer(const Duration(seconds: 2), () {
          setState(() {
            showFeedback = false;
          });
        });
      }
    }
  }

  void _resetCorrectAnswers() {
    setState(() {
      correctAnswers = 0;
    });
  }

  Color _getButtonColor(String option) {
    if (!answered) return AppColors.primary;
    final correct = currentQuestion!["answer"];
    if (option == correct) return Colors.green;
    if (option == selectedAnswer && selectedAnswer != correct) return Colors.red;
    return AppColors.primary;
  }

  @override
  void initState() {
    super.initState();
    _pickQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Text(
                  'Aciertos: $correctAnswers',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _resetCorrectAnswers,
                  icon: const Icon(Icons.refresh),
                  tooltip: "Restablecer",
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Stack(
          alignment: Alignment.center,
          children: [
            currentQuestion != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        currentQuestion!["question"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(
                            (currentQuestion!["options"] as List).length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: ElevatedButton(
                                onPressed: () => _selectAnswer(
                                    currentQuestion!["options"][index]),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getButtonColor(
                                      currentQuestion!["options"][index]),
                                      foregroundColor: Colors.white
                                ),
                                child:
                                    Text(currentQuestion!["options"][index]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Mostrar botón solo cuando ya respondió
                      if (answered && !showFeedback)
                        ElevatedButton(
                          onPressed: _pickQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white
                          ),
                          child: const Text("Siguiente pregunta"),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      const StopwatchTimer(),
                    ],
                  )
                : const SizedBox.shrink(),

            // Feedback overlay SOLO si es correcto
            if (currentQuestion != null &&
                selectedAnswer == currentQuestion?["answer"])
              IgnorePointer(
                ignoring: true,
                child: AnimatedOpacity(
                  opacity: showFeedback ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "¡Correcto!",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
