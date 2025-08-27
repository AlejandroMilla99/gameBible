import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../models/country.dart';

class GeoExpertViewModel extends ChangeNotifier {
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _rollTimer;

  bool isRolling = false;
  bool gameStarted = false;
  Country? currentCountry;
  int totalScore = 0;

  final Map<String, String> categoryEmojis = const {
    "GDP": "💰",
    "Population": "👥",
    "Safety": "🛡️",
    "Football": "⚽",
    "Happiness": "😊",
    "Tourism": "🧳",
    "Education": "🎓",
    "Technology": "💻",
  };

  final List<Country> countries = [
    Country(
      name: "Argentina",
      flag: "🇦🇷",
      rankings: {
        "GDP": 30,
        "Population": 20,
        "Safety": 40,
        "Football": 1,
        "Happiness": 25,
        "Tourism": 10,
        "Education": 15,
        "Technology": 22,
      },
    ),
    Country(
      name: "Brazil",
      flag: "🇧🇷",
      rankings: {
        "GDP": 15,
        "Population": 6,
        "Safety": 50,
        "Football": 2,
        "Happiness": 30,
        "Tourism": 5,
        "Education": 20,
        "Technology": 18,
      },
    ),
    Country(
      name: "Spain",
      flag: "🇪🇸",
      rankings: {
        "GDP": 12,
        "Population": 30,
        "Safety": 18,
        "Football": 3,
        "Happiness": 12,
        "Tourism": 4,
        "Education": 9,
        "Technology": 16,
      },
    ),
    Country(
      name: "Germany",
      flag: "🇩🇪",
      rankings: {
        "GDP": 4,
        "Population": 19,
        "Safety": 10,
        "Football": 5,
        "Happiness": 14,
        "Tourism": 6,
        "Education": 5,
        "Technology": 7,
      },
    ),
    Country(
      name: "USA",
      flag: "🇺🇸",
      rankings: {
        "GDP": 1,
        "Population": 3,
        "Safety": 25,
        "Football": 20,
        "Happiness": 17,
        "Tourism": 2,
        "Education": 6,
        "Technology": 1,
      },
    ),
    Country(
      name: "Japan",
      flag: "🇯🇵",
      rankings: {
        "GDP": 3,
        "Population": 11,
        "Safety": 5,
        "Football": 25,
        "Happiness": 20,
        "Tourism": 8,
        "Education": 4,
        "Technology": 2,
      },
    ),
    Country(
      name: "France",
      flag: "🇫🇷",
      rankings: {
        "GDP": 6,
        "Population": 22,
        "Safety": 12,
        "Football": 4,
        "Happiness": 10,
        "Tourism": 1,
        "Education": 7,
        "Technology": 10,
      },
    ),
    Country(
      name: "Italy",
      flag: "🇮🇹",
      rankings: {
        "GDP": 8,
        "Population": 23,
        "Safety": 15,
        "Football": 6,
        "Happiness": 11,
        "Tourism": 3,
        "Education": 8,
        "Technology": 12,
      },
    ),
  ];

  final List<String> categories = [
    "GDP",
    "Population",
    "Safety",
    "Football",
    "Happiness",
    "Tourism",
    "Education",
    "Technology",
  ];

  Map<String, int?> assignedRanks = {};
  Map<String, Country?> assignedCountries = {};
  List<int> topScores = [];
  final BuildContext context;

  bool buttonPressed = false;

  final ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  GeoExpertViewModel(this.context) {
    _initGame();
  }

  Future<void> _initGame() async {
    assignedRanks = {for (var c in categories) c: null};
    assignedCountries = {for (var c in categories) c: null};
    totalScore = 0;
    currentCountry = null;
    gameStarted = false;
    isRolling = false;
    await _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('geoExpertScores') ?? [];
    topScores = scores.map((s) => int.tryParse(s) ?? 0).toList();
    topScores.sort((a, b) => a.compareTo(b));
    if (topScores.length > 3) topScores = topScores.sublist(0, 3);
    notifyListeners();
  }

  Future<void> _saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    topScores.add(score);
    topScores.sort((a, b) => a.compareTo(b));
    if (topScores.length > 3) topScores = topScores.sublist(0, 3);
    await prefs.setStringList(
        'geoExpertScores', topScores.map((e) => e.toString()).toList());
    notifyListeners();
  }

    void restartGame() {
    assignedRanks = {for (var c in categories) c: null};
    assignedCountries = {for (var c in categories) c: null};
    totalScore = 0;
    currentCountry = null;
    gameStarted = false;
    isRolling = false;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 175), () => startRolling());
  }

  Future<void> startRolling() async {
    isRolling = true;
    currentCountry = null;
    notifyListeners();

    await _audioPlayer.stop();
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.play(AssetSource('sounds/roll_sound.mp3'));

    _rollTimer?.cancel();
    _rollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      currentCountry = countries[_random.nextInt(countries.length)];
      notifyListeners();
    });

    Future.delayed(const Duration(seconds: 2), () async {
      _rollTimer?.cancel();
      await _audioPlayer.stop();
      isRolling = false;
      gameStarted = true;
      notifyListeners();
    });
  }

  void assignToCategory(String category) {
    if (currentCountry == null) return;

    buttonPressed = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 150), () {
      buttonPressed = false;
      notifyListeners();
    });

    final rank = currentCountry!.rankings[category] ?? 50;
    assignedRanks[category] = rank;
    assignedCountries[category] = currentCountry;
    totalScore += rank;
    currentCountry = null;
    notifyListeners();

    if (assignedRanks.values.where((v) => v != null).length == categories.length) {
      Future.delayed(const Duration(milliseconds: 600), () => _showGameOver());
    } else {
      Future.delayed(const Duration(milliseconds: 175), () => startRolling());
    }
  }

  void _showGameOver() {
    _saveScore(totalScore);

    confettiController.play();

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
              title: const Text(
                "🎉 Game Over 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Your total score is:",
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$totalScore",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    restartGame();
                  },
                  child: const Text("Play Again"),
                )
              ],
            ),
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
  }



  @override
  void dispose() {
    _rollTimer?.cancel();
    _audioPlayer.dispose();
    confettiController.dispose();
    super.dispose();
  }
}
