import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import 'worday_ViewModel.dart';

class WordayPage extends StatelessWidget {
  final String title;
  const WordayPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WordayViewModel(),
      child: Consumer<WordayViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  onPressed: vm.resetGame,
                  icon: const Icon(Icons.refresh),
                  tooltip: "Reiniciar",
                )
              ],
            ),
            body: Column(
              children: [
                // Espaciado superior de la cuadrícula
                const SizedBox(height: 100),

                // Grid de intentos scrolleable
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

                // Teclado fijo (sticky)
                buildKeyboard(vm, context),

                // Pequeño espaciado inferior del teclado
                const SizedBox(height: 100),

                // Mensaje final
                if (vm.gameOver)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      vm.won
                          ? "¡Ganaste! La palabra era ${vm.targetWord.toUpperCase()}"
                          : "Perdiste. La palabra era ${vm.targetWord.toUpperCase()}",
                      style: TextStyle(
                        color: vm.won ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
                child: const Icon(Icons.backspace, color: Colors.white, size: 18),
                onPressed: vm.gameOver ? null : vm.removeLetter,
                backgroundColor: AppColors.primary,
              ),
          ],
        );
      }).toList(),
    );
  }
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
            side: const BorderSide(color: Colors.grey), // borde gris
          ),
        ),
        child: child,
      ),
    );
  }
}
