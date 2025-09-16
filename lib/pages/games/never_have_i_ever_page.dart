import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';
import 'package:gamebible/l10n/app_localizations.dart';

enum Category { normal, plus18, sentimental }

class NeverHaveIEverPage extends StatefulWidget {
  final String title;
  const NeverHaveIEverPage({super.key, required this.title});

  @override
  State<NeverHaveIEverPage> createState() => _NeverHaveIEverPageState();
}

class _NeverHaveIEverPageState extends State<NeverHaveIEverPage> {
  List<String> normal = [];
  List<String> plus18 = [];
  List<String> sentimentals = [];

  List<String> remainingNormal = [];
  List<String> remaining18 = [];
  List<String> remainingSentimentals = [];

  String? currentStatement;
  final _random = Random();
  bool _swipeRight = true;
  Category? _currentCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final locale = AppLocalizations.of(context)!.localeName;

    final normalString =
        await rootBundle.loadString("assets/data/$locale/questions.json");
    final plus18String =
        await rootBundle.loadString("assets/data/$locale/questions18.json");
    final sentimentalsString =
        await rootBundle.loadString("assets/data/$locale/sentimentals.json");

    final List<dynamic> normalData = json.decode(normalString);
    final List<dynamic> plus18Data = json.decode(plus18String);
    final List<dynamic> sentimentalsData = json.decode(sentimentalsString);

    setState(() {
      normal = normalData.cast<String>();
      plus18 = plus18Data.cast<String>();
      sentimentals = sentimentalsData.cast<String>();
      _resetIterationNormal();
      _resetIteration18();
      _resetIterationSentimentals();
    });
  }

  void _resetIterationNormal() {
    remainingNormal = List.from(normal)..shuffle(_random);
  }

  void _resetIteration18() {
    remaining18 = List.from(plus18)..shuffle(_random);
  }

  void _resetIterationSentimentals() {
    remainingSentimentals = List.from(sentimentals)..shuffle(_random);
  }

  void _pickNormal() {
    setState(() {
      _swipeRight = !_swipeRight;
      _currentCategory = Category.normal;
      if (remainingNormal.isEmpty) _resetIterationNormal();
      currentStatement = remainingNormal.removeAt(0);
    });
  }

  void _pick18() {
    setState(() {
      _swipeRight = !_swipeRight;
      _currentCategory = Category.plus18;
      if (remaining18.isEmpty) _resetIteration18();
      currentStatement = remaining18.removeAt(0);
    });
  }

  void _pickSentimentals() {
    setState(() {
      _swipeRight = !_swipeRight;
      _currentCategory = Category.sentimental;
      if (remainingSentimentals.isEmpty) _resetIterationSentimentals();
      currentStatement = remainingSentimentals.removeAt(0);
    });
  }

  Color _getBorderColor() {
    switch (_currentCategory) {
      case Category.normal:
        return Colors.green;
      case Category.plus18:
        return AppColors.secondary;
      case Category.sentimental:
        return AppColors.primary;
      default:
        return Colors.grey;
    }
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: Offset(_swipeRight ? 1.0 : -1.0, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(
                        position: offsetAnimation, child: child);
                  },
                  child: currentStatement == null
                      ? Text(
                          t.chooseCategory,
                          key: const ValueKey("empty"),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Container(
                          key: ValueKey(currentStatement),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getBorderColor(),
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            currentStatement!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 64,
                  onPressed: _pickNormal,
                  icon: const Icon(Icons.sentiment_satisfied,
                      color: Colors.green),
                  tooltip: t.normal,
                ),
                IconButton(
                  iconSize: 64,
                  onPressed: _pick18,
                  icon: const Icon(Icons.explicit, color: AppColors.secondary),
                  tooltip: t.plus18,
                ),
                IconButton(
                  iconSize: 64,
                  onPressed: _pickSentimentals,
                  icon: const Icon(Icons.book, color: AppColors.primary),
                  tooltip: t.sentimental,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
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
        title: t.howToPlayNeverHaveIEver,
        instructions: [
          t.nhieInstruction1,
          t.nhieInstruction2,
          t.nhieInstruction3,
          t.nhieInstruction4,
          t.nhieInstruction5,
          t.nhieInstruction6,
          t.nhieInstruction7,
        ],
        example: t.nhieExample,
        imageAsset: null,
      ),
    );
  }
}
