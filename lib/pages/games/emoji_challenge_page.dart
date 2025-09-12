import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../components/buttons/primary_button.dart';
import '../../constants/app_colors.dart';
import '../../components/stopwatch_timer.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';

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
  bool _isSubmitting = false; // NUEVO: controla el estado del botón

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

  void _submitAnswer() {
    if (_isSubmitting) return; // evita pulsaciones dobles
    setState(() {
      _isSubmitting = true; // deshabilita el botón
    });

    final answer = _controller.text.trim();
    final correct = currentChallenge!["answer"];
    final isCorrect = answer.toLowerCase() == correct!.toLowerCase();

    setState(() {
      if (isCorrect) {
        correctAnswers++;
        feedbackMessage = "¡Correcto!";
      } else {
        feedbackMessage = "Incorrecto";
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

    final matches = allChallenges
        .map((c) => c["answer"]!)
        .where((answer) => answer.toLowerCase().contains(input.toLowerCase()))
        .toList();

    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty &&
          !matches.any((m) => m.toLowerCase() == input.toLowerCase());
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Center(
                  child: Column(
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
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: _showFeedback ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          feedbackMessage ?? "",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: feedbackMessage == "¡Correcto!"
                                ? Colors.green
                                : Colors.red,
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
              ),
              child: const Text("Siguiente"),
            ),

              const SizedBox(height: AppSpacing.lg),
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
          "En pantalla verás una combinación de emojis que representan un concepto, una película, un libro o algo conocido.",
          "Tu objetivo es adivinar qué significa esa combinación y escribir la respuesta en el cuadro de texto.",
          "Pulsa 'Enviar' para comprobar si tu respuesta es correcta.",
          "Si aciertas, sumarás un punto a tu marcador de aciertos. Si fallas, se mostrará un mensaje indicando que la respuesta es incorrecta.",
          "Puedes pasar al siguiente reto pulsando el botón 'Siguiente'.",
          "Si te quedas bloqueado, puedes inspirarte con el sistema de sugerencias que aparece al escribir.",
          "También puedes retarte con el cronómetro para medir cuánto tardas en resolver cada desafío.",
          "Tu número de aciertos acumulados aparece en la parte superior, y puedes restablecerlo en cualquier momento."
        ],
        example:
            "Ejemplo: Si ves los emojis '🦁👑', la respuesta correcta sería 'The Lion King'.",
        imageAsset: null,
      ),
    );
  }
}
