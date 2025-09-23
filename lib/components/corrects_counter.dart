import 'package:flutter/material.dart';
import 'package:gamebible/l10n/app_localizations.dart';
import '../constants/app_colors.dart';

class CorrectCounter extends StatelessWidget {
  final int correctAnswers;
  final VoidCallback? onReset;
  final bool withReset;
  final String? text;

  const CorrectCounter({
    super.key,
    required this.correctAnswers,
    this.onReset,
    this.withReset = true,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final displayText = text ?? loc.correctAnswers;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: 216,
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
          mainAxisAlignment: MainAxisAlignment.center, // 👈 centra horizontalmente
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 6), // 👈 un pequeño espacio entre texto y número
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
            if (withReset) ...[
              const SizedBox(width: 8),
              Baseline(
                baseline: 30,
                baselineType: TextBaseline.alphabetic,
                child: IconButton(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh, color: AppColors.textDark),
                  tooltip: loc.reset,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
