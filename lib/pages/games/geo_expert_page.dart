import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart'; // Para el sonido
import 'package:gamebible/constants/app_colors.dart';
import '../../components/buttons/geo_button.dart';

class Country {
  final String name;
  final String flag;
  final Map<String, int> rankings;

  Country({required this.name, required this.flag, required this.rankings});
}

class GeoExpertPage extends StatefulWidget {
  const GeoExpertPage({super.key, required this.title});
  final String title;

  @override
  State<GeoExpertPage> createState() => _GeoExpertPageState();
}

class _GeoExpertPageState extends State<GeoExpertPage>
    with SingleTickerProviderStateMixin {
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

  final Random _random = Random();
  Timer? _rollTimer;
  bool isRolling = false;
  bool gameStarted = false;

  Country? currentCountry;
  int totalScore = 0;

  Map<String, int?> assignedRanks = {};
  Map<String, Country?> assignedCountries = {};
  List<int> topScores = [];

  // Animación y sonido
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnim;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    assignedRanks = {for (var c in categories) c: null};
    assignedCountries = {for (var c in categories) c: null};
    _loadHighScores();

    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _buttonScaleAnim =
        Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(
      parent: _buttonAnimController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('geoExpertScores') ?? [];
    topScores = scores.map((s) => int.tryParse(s) ?? 0).toList();
    topScores.sort((a, b) => a.compareTo(b));
    if (topScores.length > 3) topScores = topScores.sublist(0, 3);
    setState(() {});
  }

  Future<void> _saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    topScores.add(score);
    topScores.sort((b, a) => a.compareTo(b));
    if (topScores.length > 3) {
      topScores = topScores.sublist(0, 3);
    } else {
      topScores = topScores.sublist(0, topScores.length);
    }
    prefs.setStringList(
        'geoExpertScores', topScores.map((e) => e.toString()).toList());
  }

  void _startRolling() async {
    setState(() {
      isRolling = true;
      currentCountry = null;
    });

    // Sonido en bucle
    await _audioPlayer.stop();
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.play(AssetSource('sounds/roll_sound.mp3'));

    _rollTimer?.cancel();
    _rollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        currentCountry = countries[_random.nextInt(countries.length)];
      });
    });

    Future.delayed(const Duration(seconds: 2), () async {
      _rollTimer?.cancel();
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() {
        isRolling = false;
        gameStarted = true;
      });
    });
  }

  void _assignToCategory(String category) {
    if (currentCountry == null) return;

    _buttonAnimController.forward().then((_) => _buttonAnimController.reverse());

    final rank = currentCountry!.rankings[category] ?? 50;

    setState(() {
      assignedRanks[category] = rank;
      assignedCountries[category] = currentCountry;
      totalScore += rank;
      isRolling = true;
      currentCountry = null;
    });

    if (assignedRanks.values.where((v) => v != null).length == categories.length) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _showGameOver();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 175), () {
        if (mounted) _startRolling();
      });
    }
  }

  void _showHighScores() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "🏆 High Scores",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (topScores.isEmpty)
                const Text(
                  "No has acabado ningun juego aun",
                  style: TextStyle(fontSize: 16),
                )
              else
                Column(
                  children: List.generate(topScores.length, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 500 + 100 * index),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade200,
                            Colors.deepPurple.shade400
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "#${index + 1}",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${topScores[index]} pts",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameOver() {
    _saveScore(totalScore);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final confettiController =
            ConfettiController(duration: const Duration(seconds: 3));
        confettiController.play();

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
                    _restartGame();
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

  void _restartGame() {
    setState(() {
      assignedRanks = {for (var c in categories) c: null};
      assignedCountries = {for (var c in categories) c: null};
      totalScore = 0;
      currentCountry = null;
      gameStarted = false;
      isRolling = false;
    });

    Future.delayed(const Duration(milliseconds: 175), () {
      if (mounted) _startRolling();
    });
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _buttonAnimController.dispose();
    _audioPlayer.dispose();
    super.dispose();
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
            icon: const Icon(Icons.emoji_events),
            onPressed: _showHighScores,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Text(
              "Total Score: $totalScore",
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Center(
              child: currentCountry == null && !isRolling
                  ? (!gameStarted
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            textStyle: const TextStyle(fontSize: 22),
                          ),
                          onPressed: _startRolling,
                          child: const Text("Start Game"),
                        )
                      : const Text(
                          "Assign a category to continue...",
                          style: TextStyle(fontSize: 16),
                        ))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentCountry?.flag ?? "",
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentCountry?.name ?? "",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final rank = assignedRanks[cat];
                final assignedFlag = assignedCountries[cat]?.flag;
                final emoji = categoryEmojis[cat] ?? "🔹";

                final enabled =
                    (currentCountry != null && rank == null && !isRolling);

                return AnimatedBuilder(
                  animation: _buttonScaleAnim,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonScaleAnim.value,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: enabled
                              ? [
                                  BoxShadow(
                                    color: Colors.deepPurpleAccent.withOpacity(
                                        0.6 * _buttonScaleAnim.value),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  )
                                ]
                              : [],
                        ),
                        child: GeoButton(
                          category: cat,
                          emoji: emoji,
                          assignedRank: rank,
                          assignedFlag: assignedFlag,
                          enabled: enabled,
                          onPressed: () => _assignToCategory(cat),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
