import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import '../../components/stopwatch_timer.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';
import '../../components/corrects_counter.dart';

class EmojiChallengePage extends StatefulWidget {
  final String title;
  const EmojiChallengePage({super.key, required this.title});

  @override
  State<EmojiChallengePage> createState() => _EmojiChallengePageState();
}

class _EmojiChallengePageState extends State<EmojiChallengePage>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> allChallenges = [];
  List<Map<String, String>> remainingChallenges = [];
  Map<String, String>? currentChallenge;

  final _random = Random();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int correctAnswers = 0;
  String? feedbackMessage;
  bool _showFeedback = false;
  bool _isSubmitting = false; // controla el estado del botón

  List<String> _suggestions = [];
  bool _showSuggestions = false;

  Future<void> _loadChallenges() async {
    final jsonString =
        await rootBundle.loadString("assets/data/emojiGame.json");
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      allChallenges = jsonData
          .map((item) =>
              {"emoji": item["emoji"] as String, "answer": item["answer"] as String})
          .toList();
      _resetIteration();
      _pickChallenge();
    });
  }

  void _resetIteration() {
    remainingChallenges = List.from(allChallenges)..shuffle(_random);
  }

  void _pickChallenge() {
    setState(() {
      if (remainingChallenges.isEmpty) {
        _resetIteration();
      }
      currentChallenge = remainingChallenges.removeAt(0);
      _controller.clear();
      _suggestions = [];
      _showSuggestions = false;
      _isSubmitting = false; // habilitar de nuevo el botón al cargar challenge
    });
  }

/// Normaliza cadenas eliminando acentos, mayúsculas, espacios, puntuación y símbolos no alfanuméricos
  String _normalize(String text) {
    const accents = 'áéíóúÁÉÍÓÚ';
    const replacements = 'aeiouAEIOU';
    for (int i = 0; i < accents.length; i++) {
      text = text.replaceAll(accents[i], replacements[i]);
    }
    // Eliminar todo lo que no sea letra o número
    text = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return text.toLowerCase();
  }

  void _submitAnswer() {
    if (_isSubmitting) return; // evita pulsaciones dobles
    setState(() {
      _isSubmitting = true; // deshabilita el botón
    });

    final answer = _normalize(_controller.text.trim());
    final correct = _normalize(currentChallenge!["answer"]!);
    final isCorrect = answer == correct;

    setState(() {
      if (isCorrect) {
        correctAnswers++;
        feedbackMessage = "¡Correcto!";
      } else {
        feedbackMessage = "¡Incorrecto!";
      }
      _showFeedback = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
        });
        if (isCorrect && mounted) {
          _pickChallenge(); // pasa automáticamente al siguiente si acierta
        } else {
          setState(() {
            _isSubmitting = false; // reactivar si falló
          });
        }
      }
    });

    _hideKeyboard();
  }

  void _resetCorrectAnswers() {
    setState(() {
      correctAnswers = 0;
    });
  }

  void _updateSuggestions(String input) {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final normalizedInput = _normalize(input);

    final matches = allChallenges
        .map((c) => c["answer"]!)
        .where((answer) =>
            _normalize(answer).contains(normalizedInput))
        .toList();

    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty &&
          !matches.any(
              (m) => _normalize(m) == normalizedInput);
    });
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();

    _loadChallenges();

    _controller.addListener(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateSuggestions(_controller.text);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideKeyboard,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_rounded),
              onPressed: () => _showInfo(context),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CorrectCounter(
                correctAnswers: correctAnswers,
                onReset: _resetCorrectAnswers,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentChallenge != null)
                            Text(
                              currentChallenge!["emoji"]!,
                              style: const TextStyle(fontSize: 48),
                            )
                          else
                            const Text(
                              "Adivina el emoji",
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                      // Feedback positivo
                      IgnorePointer(
                        ignoring: true,
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            opacity: _showFeedback &&
                                    feedbackMessage == "¡Correcto!"
                                ? 1.0
                                : 0.0,
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
                      // Feedback negativo
                      IgnorePointer(
                        ignoring: true,
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            opacity: _showFeedback &&
                                    feedbackMessage == "¡Incorrecto!"
                                ? 1.0
                                : 0.0,
                            duration: const Duration(milliseconds: 100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "¡Incorrecto!",
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
                    ],
                  ),
                ),
              ),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Escribe tu respuesta",
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showSuggestions
                    ? Column(
                        children: _suggestions.map((suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              setState(() {
                                _controller.text = suggestion;
                                _controller.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(offset: suggestion.length),
                                );
                                _showSuggestions = false;
                              });
                              _hideKeyboard();
                            },
                          );
                        }).toList(),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor:
                      _isSubmitting ? Colors.grey : AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Enviar"),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: _pickChallenge,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Siguiente"),
              ),
              const SizedBox(height: 85),
              const StopwatchTimer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GameInfoDialog(
        title: "Cómo jugar a EmojiChallenge",
        instructions: [
          "En pantalla verás una combinación de emojis que representan un concepto, una película, un libro o alguien conocido.",
          "Tu objetivo es adivinar qué significa esa combinación y escribir la respuesta en el cuadro de texto.",
          "Pulsa 'Enviar' para comprobar si tu respuesta es correcta.",
          "Si aciertas, sumarás un punto a tu marcador de aciertos. Si fallas, se mostrará un mensaje indicando que la respuesta es incorrecta.",
          "Puedes pasar al siguiente reto pulsando el botón 'Siguiente'.",
          "Si te quedas bloqueado, puedes inspirarte con el sistema de sugerencias que aparece al escribir.",
          "También puedes retarte con el cronómetro para medir cuánto tardas en resolver cada desafío.",
          "Tu número de aciertos acumulados aparece en la parte superior, y puedes restablecerlo en cualquier momento."
        ],
        example: "Ejemplo: Si ves los emojis '🦁👑', la respuesta correcta sería 'El rey león'.",
        imageAsset: null,
      ),
    );
  }
}
