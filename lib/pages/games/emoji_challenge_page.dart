import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import '../../components/stopwatch_timer.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';
import '../../components/corrects_counter.dart';
import 'package:gamebible/l10n/app_localizations.dart';

class EmojiChallengePage extends StatefulWidget {
  final String title;
  const EmojiChallengePage({super.key, required this.title});

  @override
  State<EmojiChallengePage> createState() => _EmojiChallengePageState();
}

class _EmojiChallengePageState extends State<EmojiChallengePage>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> allChallenges = [];
  List<Map<String, String>> remainingChallenges = [];
  Map<String, String>? currentChallenge;

  final _random = Random();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int correctAnswers = 0;
  String? feedbackMessage;
  bool _showFeedback = false;
  bool _isSubmitting = false;

  List<String> _suggestions = [];
  bool _showSuggestions = false;

  Future<void> _loadChallenges() async {
    // Garantizar que AppLocalizations ya esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locale = AppLocalizations.of(context)!.localeName;
      final jsonString =
          await rootBundle.loadString("assets/data/$locale/emojiGame.json");
      final List<dynamic> jsonData = json.decode(jsonString);

      if (!mounted) return;

      setState(() {
        allChallenges = jsonData
            .map((item) =>
                {"emoji": item["emoji"] as String, "answer": item["answer"] as String})
            .toList();
        _resetIteration();
        _pickChallenge();
      });
    });
  }

  void _resetIteration() {
    remainingChallenges = List.from(allChallenges)..shuffle(_random);
  }

  void _pickChallenge() {
    setState(() {
      if (remainingChallenges.isEmpty) {
        _resetIteration();
      }
      currentChallenge = remainingChallenges.removeAt(0);
      _controller.clear();
      _suggestions = [];
      _showSuggestions = false;
      _isSubmitting = false;
    });
  }

  String _normalize(String text) {
    const accents = 'áéíóúÁÉÍÓÚ';
    const replacements = 'aeiouAEIOU';
    for (int i = 0; i < accents.length; i++) {
      text = text.replaceAll(accents[i], replacements[i]);
    }
    text = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return text.toLowerCase();
  }

  void _submitAnswer() {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final answer = _normalize(_controller.text.trim());
    final correct = _normalize(currentChallenge!["answer"]!);
    final isCorrect = answer == correct;

    final t = AppLocalizations.of(context)!;

    setState(() {
      if (isCorrect) {
        correctAnswers++;
        feedbackMessage = t.correct;
      } else {
        feedbackMessage = t.incorrect;
      }
      _showFeedback = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
        });
        if (isCorrect && mounted) {
          _pickChallenge();
        } else {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    });

    _hideKeyboard();
  }

  void _resetCorrectAnswers() {
    setState(() {
      correctAnswers = 0;
    });
  }

  void _updateSuggestions(String input) {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final normalizedInput = _normalize(input);

    final matches = allChallenges
        .map((c) => c["answer"]!)
        .where((answer) => _normalize(answer).contains(normalizedInput))
        .toList();

    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty &&
          !matches.any((m) => _normalize(m) == normalizedInput);
    });
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();

    _loadChallenges();

    _controller.addListener(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateSuggestions(_controller.text);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _hideKeyboard,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_rounded),
              onPressed: () => _showInfo(context),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CorrectCounter(
                correctAnswers: correctAnswers,
                onReset: _resetCorrectAnswers,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentChallenge != null)
                            Text(
                              currentChallenge!["emoji"]!,
                              style: const TextStyle(fontSize: 48),
                            )
                          else
                            Text(
                              t.guessEmoji,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                      IgnorePointer(
                        ignoring: true,
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            opacity: _showFeedback &&
                                    feedbackMessage == t.correct
                                ? 1.0
                                : 0.0,
                            duration: const Duration(milliseconds: 100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                t.correct,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        ignoring: true,
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            opacity: _showFeedback &&
                                    feedbackMessage == t.incorrect
                                ? 1.0
                                : 0.0,
                            duration: const Duration(milliseconds: 100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                t.incorrect,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: t.writeAnswer,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showSuggestions
                    ? Column(
                        children: _suggestions.map((suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              setState(() {
                                _controller.text = suggestion;
                                _controller.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(offset: suggestion.length),
                                );
                                _showSuggestions = false;
                              });
                              _hideKeyboard();
                            },
                          );
                        }).toList(),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor:
                      _isSubmitting ? Colors.grey : AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(t.send),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: _pickChallenge,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
                child: Text(t.next),
              ),
              const SizedBox(height: 85),
              const StopwatchTimer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => GameInfoDialog(
        title: t.howToPlayEmoji,
        instructions: [
          t.emojiInstruction1,
          t.emojiInstruction2,
          t.emojiInstruction3,
          t.emojiInstruction4,
          t.emojiInstruction5,
          t.emojiInstruction6,
          t.emojiInstruction7,
          t.emojiInstruction8,
        ],
        example: t.emojiExample,
        imageAsset: null,
      ),
    );
  }
}
