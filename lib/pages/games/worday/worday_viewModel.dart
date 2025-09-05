import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../components/dialogs/custom_snackbar.dart';

enum LetterState { unused, correct, misplaced, notInWord, fullyCorrect }

class WordayViewModel extends ChangeNotifier {
  static const int maxAttempts = 6;
  static const int wordLength = 5;

  List<String> _dictionary = []; // palabras originales con tildes
  List<String> _dictionaryNormalized = []; // mismas palabras sin tildes

  late String _targetWord; // palabra con tildes (para mostrar al usuario)
  late String _targetWordNormalized; // versión sin tildes (para lógica)
  int _currentAttempt = 0;
  List<List<String>> _guesses = List.generate(maxAttempts, (_) => []);
  List<List<Color>> _colors =
      List.generate(maxAttempts, (_) => List.filled(wordLength, Colors.grey));

  final Map<String, LetterState> letterStates = {};

  bool _gameOver = false;
  bool _won = false;

  final ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  WordayViewModel() {
    _loadDictionary().then((_) => _pickRandomWord());
  }

  /// Quita tildes de una palabra
  String _normalizeWord(String word) {
    const withAccents = 'áéíóúÁÉÍÓÚüÜ';
    const withoutAccents = 'aeiouAEIOUuU';
    String result = word;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }

  /// Cargar palabras válidas desde assets/data/words.json
  Future<void> _loadDictionary() async {
    final String response =
        await rootBundle.loadString('assets/data/words.json');
    final List<dynamic> data = json.decode(response);
    _dictionary = data.cast<String>();
    _dictionaryNormalized =
        _dictionary.map((w) => _normalizeWord(w)).toList();
  }

  void _pickRandomWord() {
    if (_dictionary.isEmpty) return; // por si no ha cargado aún
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

  /// Devuelve el estado de una letra en el teclado
  LetterState letterStatus(String letter) {
    return letterStates[letter] ?? LetterState.unused;
  }

  /// Indica si un botón debe estar deshabilitado
  bool isButtonDisabled(String letter) {
    if (_gameOver) return true; // deshabilitar todo si terminó
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

  /// Envía el guess y valida si es palabra existente
  void submitGuess(BuildContext context) {
    if (_gameOver) return;
    if (_guesses[_currentAttempt].length != wordLength) return;

    final guess = _guesses[_currentAttempt].join();
    final normalizedGuess = _normalizeWord(guess);

    // 🔑 Nueva validación: palabra debe estar en diccionario (normalizado)
    if (!_dictionaryNormalized.contains(normalizedGuess)) {
      CustomSnackBar.show(
        context,
        message: "Palabra inválida, haga otro intento",
        type: SnackBarType.warning,
      );
      return; // no avanza el intento
    }

    final targetLetters = _targetWordNormalized.split('');
    final guessLetters = normalizedGuess.split('');

    // Para manejar letras repetidas
    final Map<String, int> targetCounts = {};
    for (var c in targetLetters) {
      targetCounts[c] = (targetCounts[c] ?? 0) + 1;
    }

    // Primera pasada -> verdes
    for (int i = 0; i < wordLength; i++) {
      final letter = guessLetters[i];
      if (_targetWordNormalized[i] == letter) {
        _colors[_currentAttempt][i] = Colors.green;
        targetCounts[letter] = (targetCounts[letter] ?? 0) - 1;
        letterStates[letter] = LetterState.correct;
      }
    }

    // Segunda pasada -> naranjas y grises
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

    // Marcar fullyCorrect cuando ya no queden más instancias de esa letra en la palabra
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

  /// Mostrar el diálogo de fin de juego
  void _showGameOver(BuildContext context) {
    final validAttempts =
        _guesses.take(_currentAttempt + 1).where((g) => g.length == wordLength);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Text(
                _won ? "🎉 ¡Has acertado! 🎉" : "😢 Fin del juego 😢",
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_won)
                    Text(
                      "¡Felicidades! Acertaste en ${validAttempts.length} intentos.",
                      style: const TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      "No acertaste la palabra.\nLa correcta era: ${_targetWord.toUpperCase()}",
                      style: const TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame();
                  },
                  child: const Text("Jugar de nuevo"),
                )
              ],
            ),
            if (_won)
              ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple
                ],
              ),
          ],
        );
      },
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
