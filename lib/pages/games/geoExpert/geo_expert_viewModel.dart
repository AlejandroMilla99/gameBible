import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../models/country.dart';
import '../../../services/country_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gamebible/l10n/app_localizations.dart';

class GeoExpertViewModel extends ChangeNotifier {
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _rollTimer;

  bool isRolling = false;
  bool gameStarted = false;
  Country? currentCountry;
  int totalScore = 0;
  int skipsLeft = 3;

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
    "Pollution": "🌫️",
    "LGBTQI rights": "🏳️‍🌈"
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

  // --- Daily mode fields ---
  final bool isDailyMode;
  late AppLocalizations t;
  List<Country> _dailySequence = [];
  int _dailyIndex = 0; // next index to use from sequence
  bool _dailyAttemptStarted = false;
  bool _dailyAttemptCompleted = false;

  GeoExpertViewModel(this.context, this.isDailyMode) {
    t = AppLocalizations.of(context)!;
    _loadCountries();
  }

  Future<void> _initGame() async {
    assignedRanks = {for (var c in categories) c: null};
    assignedCountries = {for (var c in categories) c: null};
    totalScore = 0;
    currentCountry = null;
    gameStarted = false;
    isRolling = false;
    skipsLeft = 3;
    _dailyIndex = 0;
    _dailyAttemptStarted = false;
    _dailyAttemptCompleted = false;
    await _loadHighScores();

    // Si es modo diario, intentar restaurar estado anterior (si existe)
    if (isDailyMode) {
      await _restoreDailyStateIfAny();
    }
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

  String _dailyKeyForTodayCEST() {
    // Normalizamos día según CEST (UTC+2). La "hora de renovación" es a las 08:00 CEST.
    // Para determinar la "fecha del challenge" tomamos la fecha CEST actual.
    final nowUtc = DateTime.now().toUtc();
    final nowCest = nowUtc.add(const Duration(hours: 2)); // CEST = UTC+2
    final year = nowCest.year;
    final month = nowCest.month;
    final day = nowCest.day;
    // Formato YYYY-MM-DD
    return "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  void _prepareDailySequenceIfNeeded() {
    if (!isDailyMode) return;
    final key = _dailyKeyForTodayCEST();

    // Si ya calculado para esta sesión no recalcular
    if (_dailySequence.isNotEmpty) return;

    // Usa seed determinista por día para que todos los jugadores obtengan la misma secuencia
    final seed = key.hashCode;
    final rng = Random(seed);

    final temp = List<Country>.from(countries);
    // Shuffle deterministically
    for (var i = temp.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final t = temp[i];
      temp[i] = temp[j];
      temp[j] = t;
    }

    // Tomamos 11 países: 8 a jugar + 3 "skip options"
    final take = temp.length >= 11 ? 11 : temp.length;
    _dailySequence = temp.take(take).toList();
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
    skipsLeft = 3;
    currentCountry = null;
    gameStarted = false;
    isRolling = false;
    // reset daily flags (but don't remove stored daily state)
    _dailyIndex = 0;
    _dailyAttemptStarted = false;
    _dailyAttemptCompleted = false;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 100), () => startRolling());
  }

  void skipCountry() {
    if (skipsLeft <= 0) return;
    skipsLeft -= 1;

    // In daily mode advance the index (consume a sequence item)
    if (isDailyMode && _dailySequence.isNotEmpty) {
      _dailyIndex++;
      // If reached end of sequence, end attempt
      if (_dailyIndex >= _dailySequence.length) {
        // finish attempt early (mark completed? here treat as completed)
        _completeDailyAttempt();
        return;
      }
    }

    // Start rolling to next (visual animation); when it finishes,
    // startRolling() will set the final country from sequence (if daily).
    startRolling();
    _persistDailyState();
    notifyListeners();
  }

  Future<void> startRolling() async {
    // If daily mode and there's a stored attempt that was started and not completed
    // we still allow user to start a new attempt only if they haven't started today.
    if (isDailyMode) {
      _prepareDailySequenceIfNeeded();
      // if an attempt is already started and not completed, we should show game over instead of starting
      if (_dailyAttemptStarted && !_dailyAttemptCompleted) {
        // show game over immediately (abandoned previously)
        // Show a game over with penalty score 800 (as requested) and do not start a new attempt
        _showGameOver(dailyAbandoned: true);
        return;
      }
      // Mark attempt as started and persist
      _dailyAttemptStarted = true;
      _dailyAttemptCompleted = false;
      _dailyIndex = 0;
      skipsLeft = 3;
      totalScore = 0;
      _persistDailyState();
    }

    isRolling = true;
    currentCountry = null;
    notifyListeners();

    await _audioPlayer.stop();
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.play(AssetSource('sounds/roll_sound.mp3'));

    _rollTimer?.cancel();
    // During rolling show random flags for visual effect
    _rollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      currentCountry = countries[_random.nextInt(countries.length)];
      notifyListeners();
    });

    Future.delayed(const Duration(seconds: 2), () async {
      _rollTimer?.cancel();
      await _audioPlayer.stop();
      // Determine final country
      if (isDailyMode && _dailySequence.isNotEmpty) {
        // pick from pre-defined sequence at _dailyIndex
        if (_dailyIndex < _dailySequence.length) {
          currentCountry = _dailySequence[_dailyIndex];
        } else {
          // fallback to random if sequence exhausted
          currentCountry = countries[_random.nextInt(countries.length)];
        }
      } else {
        currentCountry = countries[_random.nextInt(countries.length)];
      }

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

    // In daily mode, after assigning advance the sequence index
    if (isDailyMode && _dailySequence.isNotEmpty) {
      _dailyIndex++;
    }

    currentCountry = null;
    notifyListeners();

    // Persist state in daily mode (score, index, skips)
    if (isDailyMode) {
      _persistDailyState();
    }

    if (assignedRanks.values.where((v) => v != null).length == categories.length) {
      // Completed all categories -> game over
      Future.delayed(const Duration(milliseconds: 600), () {
        // mark daily completed if in daily mode
        if (isDailyMode) {
          _dailyAttemptCompleted = true;
          _persistDailyState(completed: true);
        }
        _showGameOver();
      });
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
      _betterChoiceMessage = t.geoExpertRecommendation(best["cat"] ?? "", best["rank"] ?? "");
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

  // Persistence helpers for daily mode
  Future<void> _persistDailyState({bool completed = false}) async {
    if (!isDailyMode) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _dailyKeyForTodayCEST();
    await prefs.setBool('daily_started_$key', _dailyAttemptStarted);
    await prefs.setBool('daily_completed_$key', completed || _dailyAttemptCompleted);
    await prefs.setInt('daily_score_$key', totalScore);
    await prefs.setInt('daily_index_$key', _dailyIndex);
    await prefs.setInt('daily_skips_$key', skipsLeft);
  }

  Future<void> _restoreDailyStateIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dailyKeyForTodayCEST();
    final started = prefs.getBool('daily_started_$key') ?? false;
    final completed = prefs.getBool('daily_completed_$key') ?? false;
    final savedScore = prefs.getInt('daily_score_$key') ?? 0;
    final savedIndex = prefs.getInt('daily_index_$key') ?? 0;
    final savedSkips = prefs.getInt('daily_skips_$key') ?? 3;

    _prepareDailySequenceIfNeeded();

    // If an attempt was started previously
    if (started) {
      _dailyAttemptStarted = true;
      _dailyAttemptCompleted = completed;
      totalScore = savedScore;
      _dailyIndex = savedIndex;
      skipsLeft = savedSkips;

      // If it was not completed -> treat as abandoned and immediately show game over with penalty
      if (!completed) {
        // Show GameOver with abandonment
        // We delay to ensure view can subscribe before showing dialog
        Future.delayed(const Duration(milliseconds: 200), () {
          _showGameOver(dailyAbandoned: true);
        });
      } else {
        // If completed previously, show game over with real saved score
        Future.delayed(const Duration(milliseconds: 200), () {
          _showGameOver(dailyAbandoned: false, forcedScore: savedScore);
        });
      }
    }
  }

  void _completeDailyAttempt() {
    _dailyAttemptCompleted = true;
    _persistDailyState(completed: true);
    _showGameOver();
  }

  void _showGameOver({bool dailyAbandoned = false, int? forcedScore}) {
    // Save top score if completed normally
    if (!isDailyMode) {
      _saveScore(totalScore);
    } else {
      // In daily mode: if abandoned, use penalty score 800 (as requested).
      if (dailyAbandoned) {
        // do NOT save 800 as top score, but show it to the user
      } else {
        // Save completed daily score as top score too
        if (_dailyAttemptCompleted || forcedScore != null) {
          _saveScore(forcedScore ?? totalScore);
        }
      }
    }

    confettiController.play();

    // Build message text depending on daily mode / abandoned / forcedScore
    final displayScore = forcedScore ?? (dailyAbandoned ? 800 : totalScore);
    final title = t.gameOver;

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
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isDailyMode
                        ? (dailyAbandoned ? t.geoExpertAbandonTryDaily : t.geoExpertFinalScoreDaily)
                        : t.geoExpertFinalScoreNormal,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$displayScore 🏆",
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
                    // If daily mode and user wants to retry (not allowed when daily), treat accordingly:
                    if (isDailyMode) {
                      // In daily mode, 'Play Again' should restart only in normal mode.
                      // We'll call restartGame which resets local state but daily attempt restrictions remain saved.
                      Navigator.of(context).pop();
                    } else {
                      restartGame();
                    }
                  },
                  child: Text(isDailyMode ? t.back : t.playAgain)
                ),
                ElevatedButton(
                  onPressed: () {
                    final shareText = t.geoExpertShareText(displayScore);
                    // Compartir con share_plus
                    SharePlus.instance.share(ShareParams(text: shareText));
                  },
                  child: Text(t.share),
                ),
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
