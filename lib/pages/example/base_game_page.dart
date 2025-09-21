import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_game_viewModel.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../components/corrects_counter.dart';
import '../../components/stopwatch_timer.dart';
import 'package:gamebible/l10n/app_localizations.dart';

/// Vista base de un minijuego.
/// Usa un ViewModel separado para la lógica.
class BaseGamePage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> challenges; // Lo inyectas desde fuera

  const BaseGamePage({super.key, required this.title, required this.challenges});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = BaseGameViewModel();
        vm.init(challenges);
        return vm;
      },
      child: _BaseGameView(title: title),
    );
  }
}

class _BaseGameView extends StatelessWidget {
  final String title;
  const _BaseGameView({required this.title});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final vm = context.watch<BaseGameViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CorrectCounter(
              correctAnswers: vm.correctAnswers,
              onReset: vm.resetCorrectAnswers,
            ),
            const SizedBox(height: AppSpacing.md),

            // --- Contenido central genérico (ejemplo con emoji/imagen) ---
            Expanded(
              child: Center(
                child: vm.currentChallenge != null
                    ? Text(
                        vm.currentChallenge!["emoji"] ?? "🤔",
                        style: const TextStyle(fontSize: 48),
                      )
                    : Text(t.loading),
              ),
            ),

            // --- Botones ---
            ElevatedButton(
              onPressed: vm.isSubmitting
                  ? null
                  : () {
                      // Aquí puedes inyectar normalizador y textos desde la vista
                      vm.submitAnswer(
                        "respuesta", // <- reemplazar por input real
                        _normalize,
                        t.correct,
                        t.incorrect,
                      );
                    },
              child: Text(t.send),
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton(
              onPressed: vm.pickChallenge,
              child: Text(t.next),
            ),

            const SizedBox(height: 85),
            const StopwatchTimer(),
          ],
        ),
      ),
    );
  }

  // Función auxiliar (se puede mover a utils)
  String _normalize(String text) {
    const accents = 'áéíóúÁÉÍÓÚ';
    const replacements = 'aeiouAEIOU';
    for (int i = 0; i < accents.length; i++) {
      text = text.replaceAll(accents[i], replacements[i]);
    }
    text = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return text.toLowerCase();
  }
}
