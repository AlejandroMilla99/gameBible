import 'dart:math';
import 'package:flutter/foundation.dart';

/// ViewModel base para un minijuego
/// Encargado de manejar el estado y la lógica
class BaseGameViewModel extends ChangeNotifier {
  final Random _random = Random();

  // --- Estado del juego ---
  int correctAnswers = 0;
  bool isSubmitting = false;
  bool showFeedback = false;
  String? feedbackMessage;

  // Ejemplo: lista de retos genéricos
  List<Map<String, String>> allChallenges = [];
  List<Map<String, String>> remainingChallenges = [];
  Map<String, String>? currentChallenge;

  // --- Métodos principales ---
  void init(List<Map<String, String>> challenges) {
    allChallenges = challenges;
    _resetIteration();
    pickChallenge();
  }

  void _resetIteration() {
    remainingChallenges = List.from(allChallenges)..shuffle(_random);
  }

  void pickChallenge() {
    if (remainingChallenges.isEmpty) {
      _resetIteration();
    }
    currentChallenge = remainingChallenges.removeAt(0);
    showFeedback = false;
    isSubmitting = false;
    notifyListeners();
  }

  void submitAnswer(String input, String Function(String) normalize, String correctMsg, String incorrectMsg) {
    if (isSubmitting || currentChallenge == null) return;
    isSubmitting = true;

    final answer = normalize(input.trim());
    final correct = normalize(currentChallenge!["answer"] ?? "");
    final isCorrect = answer == correct;

    if (isCorrect) {
      correctAnswers++;
      feedbackMessage = correctMsg;
    } else {
      feedbackMessage = incorrectMsg;
    }

    showFeedback = true;
    notifyListeners();
  }

  void resetCorrectAnswers() {
    correctAnswers = 0;
    notifyListeners();
  }
}
