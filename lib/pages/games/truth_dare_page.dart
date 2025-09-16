import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';
import 'package:gamebible/l10n/app_localizations.dart';

enum ChallengeCategory { truth, dare }

class TruthDarePage extends StatefulWidget {
  final String title;
  const TruthDarePage({super.key, required this.title});

  @override
  State<TruthDarePage> createState() => _TruthDarePageState();
}

class _TruthDarePageState extends State<TruthDarePage> {
  List<String> truths = [];
  List<String> dares = [];

  List<String> remainingTruths = [];
  List<String> remainingDares = [];

  String? currentChallenge;
  final _random = Random();
  bool _swipeRight = true;
  ChallengeCategory? _currentCategory;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final locale = AppLocalizations.of(context)!.localeName;
    final truthsString =
        await rootBundle.loadString("assets/data/$locale/truths.json");
    final daresString =
        await rootBundle.loadString("assets/data/$locale/dares.json");

    final List<dynamic> truthsData = json.decode(truthsString);
    final List<dynamic> daresData = json.decode(daresString);

    setState(() {
      truths = truthsData.cast<String>();
      dares = daresData.cast<String>();
      _resetIterationTruths();
      _resetIterationDares();
    });
  }

  void _resetIterationTruths() {
    remainingTruths = List.from(truths)..shuffle(_random);
  }

  void _resetIterationDares() {
    remainingDares = List.from(dares)..shuffle(_random);
  }

  void _pickTruth() {
    if (truths.isEmpty) return;

    setState(() {
      _swipeRight = !_swipeRight;
      _currentCategory = ChallengeCategory.truth;

      if (remainingTruths.isEmpty) _resetIterationTruths();

      currentChallenge = remainingTruths.removeAt(0);
    });
  }

  void _pickDare() {
    if (dares.isEmpty) return;

    setState(() {
      _swipeRight = !_swipeRight;
      _currentCategory = ChallengeCategory.dare;

      if (remainingDares.isEmpty) _resetIterationDares();

      currentChallenge = remainingDares.removeAt(0);
    });
  }

  Color _getBorderColor() {
    switch (_currentCategory) {
      case ChallengeCategory.truth:
        return Colors.blue;
      case ChallengeCategory.dare:
        return Colors.red;
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
                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                  child: currentChallenge == null
                      ? Text(
                          t.chooseTruthOrDare,
                          key: const ValueKey("empty"),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Container(
                          key: ValueKey(currentChallenge),
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
                            currentChallenge!,
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
                  onPressed: _pickTruth,
                  icon: const Icon(Icons.question_answer, color: Colors.blue),
                  tooltip: t.truth,
                ),
                IconButton(
                  iconSize: 64,
                  onPressed: _pickDare,
                  icon: const Icon(Icons.local_fire_department, color: Colors.red),
                  tooltip: t.dare,
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
        title: t.howToPlayTruthOrDare,
        instructions: [
          t.instruction1,
          t.instruction2,
          t.instruction3,
          t.instruction4,
          t.instruction5,
        ],
        example: t.example,
        imageAsset: null,
      ),
    );
  }
}
