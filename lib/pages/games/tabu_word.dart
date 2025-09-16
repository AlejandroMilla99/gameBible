import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';
import 'package:gamebible/components/stopwatch_timer.dart';
import '../../components/corrects_counter.dart';
import 'package:gamebible/l10n/app_localizations.dart';

class TabuWordPage extends StatefulWidget {
  final String title;
  const TabuWordPage({super.key, required this.title});

  @override
  State<TabuWordPage> createState() => _TabuWordPageState();
}

class _TabuWordPageState extends State<TabuWordPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allCards = [];
  List<Map<String, dynamic>> availableCards = [];
  Map<String, dynamic>? currentCard;
  int correctCount = 0;

  @override
  void initState() {
    super.initState();
  }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final locale = AppLocalizations.of(context)!.localeName;
    final response = await rootBundle.loadString("assets/data/$locale/tabu.json");
    final List<dynamic> data = jsonDecode(response);
    setState(() {
      allCards = data.map((e) => Map<String, dynamic>.from(e)).toList();
      availableCards = List.from(allCards);
      availableCards.shuffle();
    });
  }

  void _pickCard({bool increment = false}) {
    if (availableCards.isEmpty) {
      availableCards = List.from(allCards);
      availableCards.shuffle();
    }
    setState(() {
      currentCard = availableCards.removeAt(0);
      if (increment) correctCount++;
    });
  }

  void _resetCorrectCount() {
    setState(() {
      correctCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_rounded),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: allCards.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  CorrectCounter(
                    correctAnswers: correctCount,
                    onReset: _resetCorrectCount,
                  ),
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ));
                          return SlideTransition(
                            position: offsetAnimation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: currentCard == null
                            ? Text(
                                t.pressToStart,
                                key: const ValueKey("empty"),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                                textAlign: TextAlign.center,
                              )
                            : Container(
                                key: ValueKey(currentCard!["word"]),
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentCard!["word"],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      t.forbiddenWords,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GridView.count(
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 4,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      childAspectRatio: 3.5,
                                      children: (currentCard!["forbidden"]
                                              as List<dynamic>)
                                          .map((word) => Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.red[100],
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                child: Text(
                                                  word.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (currentCard == null) ...[
                    ElevatedButton(
                      onPressed: () => _pickCard(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                      ),
                      child: Text(
                        t.start,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickCard(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                          ),
                          child: Text(t.discard,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        ElevatedButton(
                          onPressed: () => _pickCard(increment: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                          ),
                          child: Text(t.correct,
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.bottomPadding),
                  const StopwatchTimer(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => GameInfoDialog(
        title: t.howToPlayTabu,
        instructions: [
          t.tabuInstruction1,
          t.tabuInstruction2,
          t.tabuInstruction3,
          t.tabuInstruction4,
          t.tabuInstruction5,
        ],
        example: t.tabuExample,
        imageAsset: null,
      ),
    );
  }
}
