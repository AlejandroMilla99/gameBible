import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../components/dialogs/custom_snackbar.dart';
import '../../../components/dialogs/general_dialog.dart';
import 'package:gamebible/l10n/app_localizations.dart';

enum LetterState { unused, correct, misplaced, notInWord, fullyCorrect }

class WordayViewModel extends ChangeNotifier {
  static const int maxAttempts = 6;
  static const int wordLength = 5;

  List<String> _dictionary = [];
  List<String> _dictionaryNormalized = [];

  late String _targetWord;
  late String _targetWordNormalized;
  int _currentAttempt = 0;
  List<List<String>> _guesses = List.generate(maxAttempts, (_) => []);
  List<List<Color>> _colors =
      List.generate(maxAttempts, (_) => List.filled(wordLength, Colors.grey));

  final Map<String, LetterState> letterStates = {};

  bool _gameOver = false;
  bool _won = false;

  final ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  WordayViewModel();

  /// Normaliza palabra quitando tildes
  String _normalizeWord(String word) {
    const withAccents = 'áéíóúÁÉÍÓÚüÜ';
    const withoutAccents = 'aeiouAEIOUuU';
    String result = word;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }

  /// Carga el diccionario según el locale actual
  Future<void> loadDictionary(BuildContext context) async {
    final locale = AppLocalizations.of(context)!.localeName;
    final String response =
        await rootBundle.loadString('assets/data/$locale/words.json');
    final List<dynamic> data = json.decode(response);
    _dictionary = data.cast<String>();
    _dictionaryNormalized =
        _dictionary.map((w) => _normalizeWord(w)).toList();
    _pickRandomWord();
    notifyListeners();
  }

  void _pickRandomWord() {
    if (_dictionary.isEmpty) return;
    final random = Random();
    _targetWord = _dictionary[random.nextInt(_dictionary.length)];
    _targetWordNormalized = _normalizeWord(_targetWord);
  }

  String get targetWord => _targetWord;
  int get currentAttempt => _currentAttempt;
  List<List<String>> get guesses => _guesses;
  List<List<Color>> get colors => _colors;
  bool get gameOver => _gameOver;
  bool get won => _won;

  LetterState letterStatus(String letter) {
    return letterStates[letter] ?? LetterState.unused;
  }

  bool isButtonDisabled(String letter) {
    if (_gameOver) return true;
    final state = letterStates[letter];
    return state == LetterState.notInWord || state == LetterState.fullyCorrect;
  }

  void addLetter(String letter) {
    if (_gameOver) return;
    if (_guesses[_currentAttempt].length < wordLength) {
      _guesses[_currentAttempt].add(letter.toLowerCase());
      notifyListeners();
    }
  }

  void removeLetter() {
    if (_gameOver) return;
    if (_guesses[_currentAttempt].isNotEmpty) {
      _guesses[_currentAttempt].removeLast();
      notifyListeners();
    }
  }

  void submitGuess(BuildContext context) {
    if (_gameOver) return;
    if (_guesses[_currentAttempt].length != wordLength) return;

    final t = AppLocalizations.of(context)!;

    final guess = _guesses[_currentAttempt].join();
    final normalizedGuess = _normalizeWord(guess);

    if (!_dictionaryNormalized.contains(normalizedGuess)) {
      CustomSnackBar.show(
        context,
        message: t.invalidWord,
        type: SnackBarType.warning,
      );
      return;
    }

    final targetLetters = _targetWordNormalized.split('');
    final guessLetters = normalizedGuess.split('');

    final Map<String, int> targetCounts = {};
    for (var c in targetLetters) {
      targetCounts[c] = (targetCounts[c] ?? 0) + 1;
    }

    for (int i = 0; i < wordLength; i++) {
      final letter = guessLetters[i];
      if (_targetWordNormalized[i] == letter) {
        _colors[_currentAttempt][i] = Colors.green;
        targetCounts[letter] = (targetCounts[letter] ?? 0) - 1;
        letterStates[letter] = LetterState.correct;
      }
    }

    for (int i = 0; i < wordLength; i++) {
      final letter = guessLetters[i];
      if (_colors[_currentAttempt][i] == Colors.green) continue;

      if ((targetCounts[letter] ?? 0) > 0) {
        _colors[_currentAttempt][i] = Colors.orange;
        targetCounts[letter] = targetCounts[letter]! - 1;
        if (letterStates[letter] != LetterState.correct) {
          letterStates[letter] = LetterState.misplaced;
        }
      } else {
        _colors[_currentAttempt][i] = Colors.grey.shade600;
        if (!letterStates.containsKey(letter) ||
            letterStates[letter] == LetterState.unused) {
          letterStates[letter] = LetterState.notInWord;
        }
      }
    }

    for (var entry in targetCounts.entries) {
      if (entry.value == 0 && letterStates[entry.key] == LetterState.correct) {
        letterStates[entry.key] = LetterState.fullyCorrect;
      }
    }

    if (normalizedGuess == _targetWordNormalized) {
      _gameOver = true;
      _won = true;
      _showGameOver(context);
    } else if (_currentAttempt == maxAttempts - 1) {
      _gameOver = true;
      _won = false;
      _showGameOver(context);
    } else {
      _currentAttempt++;
    }

    notifyListeners();
  }

  void _showGameOver(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final validAttempts =
        _guesses.take(_currentAttempt + 1).where((g) => g.length == wordLength);

    GeneralDialogWidget.show(
      context,
      title: _won ? t.winTitle : t.loseTitle,
      description: _won
          ? t.winDescription(_targetWord.toUpperCase(), validAttempts.length)
          : t.loseDescription(_targetWord.toUpperCase()),
      actions: [
        GeneralDialogAction(
          label: t.playAgain,
          onPressed: () {
            Navigator.of(context).pop();
            resetGame();
          },
        ),
      ],
      showConfetti: _won,
      confettiController: confettiController,
    );

    if (_won) confettiController.play();
  }

  void resetGame() {
    _currentAttempt = 0;
    _guesses = List.generate(maxAttempts, (_) => []);
    _colors =
        List.generate(maxAttempts, (_) => List.filled(wordLength, Colors.grey));
    letterStates.clear();
    _gameOver = false;
    _won = false;
    _pickRandomWord();
    notifyListeners();
  }
}
