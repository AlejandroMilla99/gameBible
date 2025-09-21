import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../models/country.dart';
import '../../../services/country_service.dart';

class GeoExpertViewModel extends ChangeNotifier {
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _rollTimer;

  bool isRolling = false;
  bool gameStarted = false;
  Country? currentCountry;
  int totalScore = 0;

  final Map<String, String> _allCategoryEmojis = const {
    "HDI": "🌐",
    "Population": "👥",
    "GDP nominal": "💰",
    "GDP per capita": "💵",
    "Biggest area": "🌍",
    "Smallest area": "🗺️",
    "Happiness": "😊",
    "Life Expectancy": "⏳",
    "Safety": "🛡️",
    "Ecofriendly": "🌱",
    "Football": "⚽",
    "Basketball": "🏀",
    "Olympic medals": "🥇",
    "Crime": "🚔",
    "Healthcare": "🏥",
    "Education": "🎓",
    "Hottest": "🔥",
    "Coldest": "❄️",
    "Weather": "🌤️",
    "Coastline": "🏖️",
    "Corruption": "💸",
    "Poverty": "🥀",
    "Tourism": "🧳",
    "Military": "🎖️",
    "Mobile users": "📱",
    "Technology": "💻",
    "Cuisine": "🍽️",
    "Coffee": "☕",
    "Pollution": "🌫️"
  };


  late List<Country> countries;

  List<String> categories = [];
  Map<String, String> categoryEmojis = {};
  Map<String, String> categoryLabels = {};

  Map<String, int?> assignedRanks = {};
  Map<String, Country?> assignedCountries = {};
  List<int> topScores = [];
  final BuildContext context;

  bool buttonPressed = false;

  final ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  // --- POPUP better choice ---
  bool _showBetterChoicePopup = false;
  String? _betterChoiceMessage;

  // ✅ getter y setter público
  bool get showBetterChoicePopup => _showBetterChoicePopup;
  set showBetterChoicePopup(bool value) {
    _showBetterChoicePopup = value;
    notifyListeners();
  }

  String? get betterChoiceMessage => _betterChoiceMessage;

  GeoExpertViewModel(this.context) {
    _loadCountries();
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

  Future<void> _loadCountries() async {
    countries = await CountryService.loadCountries();
    _selectRandomCategories();
    await _initGame();
    notifyListeners();
  }

  void _selectRandomCategories() {
    if (countries.isEmpty) return;

    final allKeys = countries.first.rankings.keys.toList();
    allKeys.shuffle(_random);
    categories = allKeys.take(8).toList();

    final availableEmojis = _allCategoryEmojis.entries.toList();
    availableEmojis.shuffle(_random);

    categoryEmojis = {};
    categoryLabels = {};
    for (var i = 0; i < categories.length; i++) {
      final key = categories[i];
      final emoji =
          _allCategoryEmojis[key] ?? availableEmojis[i % availableEmojis.length].value;
      categoryEmojis[key] = emoji;
      categoryLabels[key] = "$emoji $key";
    }
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
    _selectRandomCategories();
    assignedRanks = {for (var c in categories) c: null};
    assignedCountries = {for (var c in categories) c: null};
    totalScore = 0;
    currentCountry = null;
    gameStarted = false;
    isRolling = false;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 100), () => startRolling());
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

    _checkBetterChoicePopup(category);

    currentCountry = null;
    notifyListeners();

    if (assignedRanks.values.where((v) => v != null).length == categories.length) {
      Future.delayed(const Duration(milliseconds: 600), () => _showGameOver());
    } else {
      Future.delayed(const Duration(milliseconds: 175), () => startRolling());
    }
  }

  void _checkBetterChoicePopup(String chosenCategory) {
    if (currentCountry == null) return;
    final chosenRank = currentCountry!.rankings[chosenCategory] ?? 100;

    final betterOption = categories
        .where((c) => assignedRanks[c] == null && c != chosenCategory)
        .map((c) {
      return {"cat": c, "rank": currentCountry!.rankings[c] ?? 100};
    }).where((entry) => (entry["rank"] as int) < chosenRank)
      .toList();

    if (betterOption.isNotEmpty) {
      final best = betterOption.reduce(
          (a, b) => (a["rank"] as int) < (b["rank"] as int) ? a : b);
      _betterChoiceMessage =
          "⚡ Podrías haber elegido mejor: ${best["cat"]} (Rank ${best["rank"]})";
      _showBetterChoicePopup = true;
      notifyListeners();

      // ✅ Ocultar popup a los 3 segundos solo si sigue visible
      Future.delayed(const Duration(seconds: 3), () {
        if (_showBetterChoicePopup) {
          _showBetterChoicePopup = false;
          _betterChoiceMessage = null;
          notifyListeners();
        }
      });
    }
  }

  void dismissBetterChoicePopup() {
    _showBetterChoicePopup = false;
    _betterChoiceMessage = null;
    notifyListeners();
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
