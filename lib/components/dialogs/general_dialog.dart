import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class GeneralDialogAction {
  final String label;
  final VoidCallback onPressed;

  GeneralDialogAction({
    required this.label,
    required this.onPressed,
  });
}

class GeneralDialogWidget {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    required List<GeneralDialogAction> actions,
    bool showConfetti = false,
    ConfettiController? confettiController,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Dialog",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              content: Text(
                description,
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;
                final isPrimary = index.isOdd; // impar → primary

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPrimary ? Colors.blue : Colors.grey[300],
                      foregroundColor: isPrimary ? Colors.white : Colors.black,
                    ),
                    onPressed: action.onPressed,
                    child: Text(action.label),
                  ),
                );
              }).toList(),
            ),
            if (showConfetti && confettiController != null)
              ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
          ],
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
