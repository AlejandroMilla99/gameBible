import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../components/buttons/primary_button.dart';
import '../../constants/app_colors.dart';
import '../../components/stopwatch_timer.dart';

class EmojiChallengePage extends StatefulWidget {
  final String title;
  const EmojiChallengePage({super.key, required this.title});

  @override
  State<EmojiChallengePage> createState() => _EmojiChallengePageState();
}

class _EmojiChallengePageState extends State<EmojiChallengePage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> challenges = [
    {"emoji": "🐍🍎", "answer": "Python"},
    {"emoji": "👑💍", "answer": "The Lord of the Rings"},
    {"emoji": "🦁👑", "answer": "The Lion King"},
  ];

  Map<String, String>? currentChallenge;
  final _random = Random();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int correctAnswers = 0;
  String? feedbackMessage;
  bool _showFeedback = false;

  List<String> _suggestions = [];
  bool _showSuggestions = false;

  void _pickChallenge() {
    setState(() {
      currentChallenge = challenges[_random.nextInt(challenges.length)];
      _controller.clear();
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  void _submitAnswer() {
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
        });
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

    final matches = challenges
        .map((c) => c["answer"]!)
        .where((answer) =>
            answer.toLowerCase().contains(input.toLowerCase()))
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickChallenge();
      _hideKeyboard();
    });

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
              PrimaryButton(
                onPressed: _submitAnswer,
                text: "Enviar",
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                onPressed: _pickChallenge,
                text: "Siguiente",
              ),
              const SizedBox(height: AppSpacing.lg),
              const StopwatchTimer(),
            ],
          ),
        ),
      ),
    );
  }
}
