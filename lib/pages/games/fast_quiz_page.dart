import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import '../../components/stopwatch_timer.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';

class FastQuizPage extends StatefulWidget {
  final String title;
  const FastQuizPage({super.key, required this.title});

  @override
  State<FastQuizPage> createState() => _FastQuizPageState();
}

class _FastQuizPageState extends State<FastQuizPage> {
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> _remainingQuestions = [];
  Map<String, dynamic>? currentQuestion;
  String? selectedAnswer;
  bool answered = false;
  bool showFeedback = false;
  final _random = Random();

  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response =
        await rootBundle.loadString('assets/data/quiz.json');
    final List<dynamic> data = jsonDecode(response);
    setState(() {
      questions = data.map((e) => Map<String, dynamic>.from(e)).toList();
      _resetIteration();
      _pickQuestion();
    });
  }

  void _resetIteration() {
    _remainingQuestions = List<Map<String, dynamic>>.from(questions);
    _remainingQuestions.shuffle(_random);
  }

  void _pickQuestion() {
    if (_remainingQuestions.isEmpty) {
      _resetIteration(); // Nueva iteración si se acabaron todas
    }
    setState(() {
      currentQuestion = _remainingQuestions.removeLast();
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
        showFeedback = answer == correct;
        if (answer == correct) correctAnswers++;
      });

      if (answer == correct) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_rounded),
            onPressed: () => _showInfo(context),
          ),
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
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Sección de preguntas centrada verticalmente
                  Center(
                    child: currentQuestion != null
                        ? SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Texto de aciertos centrado encima de la pregunta
                                Text(
                                  'Aciertos: $correctAnswers',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Pregunta
                                Text(
                                  currentQuestion!["question"],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Opciones
                                IntrinsicWidth(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: List.generate(
                                      (currentQuestion!["options"] as List)
                                          .length,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: ElevatedButton(
                                          onPressed: () => _selectAnswer(
                                              currentQuestion!["options"]
                                                  [index]),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _getButtonColor(
                                                currentQuestion!["options"]
                                                    [index]),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(currentQuestion!["options"]
                                              [index]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 80), // espacio para el botón
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Feedback overlay centrado
                  if (currentQuestion != null &&
                      selectedAnswer == currentQuestion?["answer"])
                    IgnorePointer(
                      ignoring: true,
                      child: Align(
                        alignment: Alignment.center,
                        child: AnimatedOpacity(
                          opacity: showFeedback ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 100),
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
                    ),

                  // Botón siguiente pregunta fijo, fuera del scroll
                  if (answered && !showFeedback)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: ElevatedButton(
                          onPressed: _pickQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Siguiente pregunta"),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Cronómetro fijo al final
            const StopwatchTimer(),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GameInfoDialog(
        title: "Cómo jugar a FastQuiz",
        instructions: [
          "En pantalla aparecerá una pregunta con varias opciones de respuesta.",
          "Lee atentamente la pregunta y selecciona una de las opciones disponibles.",
          "Si aciertas, la opción se marcará en verde y sumarás un punto a tu marcador de aciertos.",
          "Si fallas, tu respuesta se marcará en rojo y no sumarás puntos.",
          "Después de responder, pulsa 'Siguiente pregunta' para continuar.",
          "Puedes consultar tu número total de aciertos en la parte superior de la pantalla y restablecerlo en cualquier momento.",
          "También puedes hacer uso del cronómetro incorporado para retarte en un tiempo determinado."
        ],
        example:
            "Ejemplo: Si aparece la pregunta '¿Cuál es la capital de Francia?' y eliges 'París', tu respuesta será correcta y sumarás un punto.",
        imageAsset: null,
      ),
    );
  }
}
