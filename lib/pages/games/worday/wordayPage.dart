import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import 'worday_ViewModel.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';
import 'package:gamebible/l10n/app_localizations.dart';

class WordayPage extends StatefulWidget {
  final String title;
  final bool isDailyMode;
  const WordayPage({super.key, required this.title, required this.isDailyMode});

  @override
  State<WordayPage> createState() => _WordayPageState();
}

class _WordayPageState extends State<WordayPage> {
  late WordayViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = WordayViewModel();
    // Espera al primer frame para poder usar context y cargar el diccionario dinámico
    WidgetsBinding.instance.addPostFrameCallback((_) {
       vm.loadDictionary(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<WordayViewModel>.value(
      value: vm,
      child: Consumer<WordayViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.isDailyMode ? widget.title + " Ranked" : widget.title),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_rounded),
                  onPressed: () => _showInfo(context),
                ),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: 75),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        WordayViewModel.maxAttempts,
                        (row) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            WordayViewModel.wordLength,
                            (col) {
                              String letter = "";
                              if (vm.guesses[row].length > col) {
                                letter = vm.guesses[row][col].toUpperCase();
                              }
                              return Container(
                                margin: const EdgeInsets.all(2),
                                width: 42,
                                height: 42,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: vm.colors[row][col],
                                  border: Border.all(color: Colors.black54),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                buildKeyboard(vm, context),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: vm.resetGame,
                      child: Text(t.resetGame),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildKeyboard(WordayViewModel vm, BuildContext context) {
    const rows = [
      "QWERTYUIOP",
      "ASDFGHJKLÑ",
      "ZXCVBNM",
    ];

    return Column(
      children: rows.map((row) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 0,
          runSpacing: 0,
          children: [
            if (row == "ZXCVBNM")
              _KeyboardButton(
                onPressed: vm.gameOver ? null : () => vm.submitGuess(context),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ...row.split("").map((letter) {
              final status = vm.letterStatus(letter.toLowerCase());
              final isDisabled =
                  vm.gameOver || status == LetterState.notInWord;

              Color bg;
              if (status == LetterState.notInWord) {
                bg = Colors.grey.shade600;
              } else if (status == LetterState.correct ||
                  status == LetterState.fullyCorrect) {
                bg = Colors.green;
              } else if (status == LetterState.misplaced) {
                bg = Colors.orange;
              } else {
                bg = AppColors.primary;
              }

              return _KeyboardButton(
                onPressed: isDisabled ? null : () => vm.addLetter(letter),
                backgroundColor: bg,
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              );
            }),
            if (row == "ZXCVBNM")
              _KeyboardButton(
                onPressed: vm.gameOver ? null : vm.removeLetter,
                backgroundColor: AppColors.primary,
                child:
                    const Icon(Icons.backspace, color: Colors.white, size: 18),
              ),
          ],
        );
      }).toList(),
    );
  }
}

void _showInfo(BuildContext context) {
  final t = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (context) => GameInfoDialog(
      title: t.howToPlayWorday,
      instructions: [
        t.wordayInstruction1,
        t.wordayInstruction2,
        t.wordayInstruction3,
        t.wordayInstruction4,
      ],
      example: t.wordayExample,
      imageAsset: null,
    ),
  );
}

/// Botón personalizado para teclado, con borde gris
class _KeyboardButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  const _KeyboardButton({
    required this.child,
    this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36.8,
      height: 48.3,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: Colors.grey),
          ),
        ),
        child: child,
      ),
    );
  }
}
