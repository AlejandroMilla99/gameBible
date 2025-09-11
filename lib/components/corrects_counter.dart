import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CorrectCounter extends StatelessWidget {
  final int correctAnswers;
  final VoidCallback onReset;

  const CorrectCounter({
    super.key,
    required this.correctAnswers,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'Aciertos: ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            ClipRect(
              child: SizedBox(
                height: 28,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  child: Text(
                    '$correctAnswers',
                    key: ValueKey<int>(correctAnswers),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Botón de reset alineado
            Baseline(
              baseline: 20,
              baselineType: TextBaseline.alphabetic,
              child: IconButton(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, color: AppColors.textDark),
                tooltip: "Restablecer",
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
