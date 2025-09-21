import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamebible/constants/app_colors.dart';
import 'geo_expert_viewModel.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';
import 'package:gamebible/components/dialogs/custom_snackbar.dart';

class GeoExpertPage extends StatefulWidget {
  const GeoExpertPage({super.key, required this.title});
  final String title;

  @override
  State<GeoExpertPage> createState() => _GeoExpertPageState();
}

class _GeoExpertPageState extends State<GeoExpertPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GeoExpertViewModel(context),
      child: Consumer<GeoExpertViewModel>(
        builder: (context, vm, child) {
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
                IconButton(
                  icon: const Icon(Icons.emoji_events),
                  onPressed: () => _showHighScores(context, vm.topScores),
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        "Total Score: ${vm.totalScore}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: Center(
                        child: vm.currentCountry == null && !vm.isRolling
                            ? (!vm.gameStarted
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 20,
                                      ),
                                      textStyle: const TextStyle(fontSize: 22),
                                    ),
                                    onPressed: vm.startRolling,
                                    child: const Text("Start Game"),
                                  )
                                : const Text(
                                    "",
                                    style: TextStyle(fontSize: 16),
                                  ))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    vm.currentCountry?.flag ?? "",
                                    style: const TextStyle(fontSize: 80),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    vm.currentCountry?.name ?? "",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: vm.categories.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index < vm.categories.length) {
                            final cat = vm.categories[index];
                            final rank = vm.assignedRanks[cat];
                            final assignedFlag = vm.assignedCountries[cat]?.flag;
                            final emoji = vm.categoryEmojis[cat] ?? "🔹";

                            final enabled = (vm.currentCountry != null &&
                                rank == null &&
                                !vm.isRolling);

                            // Colores del gradiente según ranking
                            List<Color> gradientColors = [
                              Colors.grey.shade700,
                              Colors.grey.shade400
                            ];
                            if (rank != null) {
                              if (rank <= 25) {
                                gradientColors = [
                                  Colors.green.shade300,
                                  Colors.green.shade600
                                ];
                              } else if (rank > 25 && rank <= 75) {
                                gradientColors = [
                                  Colors.orange.shade300,
                                  Colors.orange.shade600
                                ];
                              } else if (rank > 75) {
                                gradientColors = [
                                  Colors.red.shade300,
                                  Colors.red.shade600
                                ];
                              }
                            }

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: gradientColors),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: enabled
                                      ? () => vm.assignToCategory(cat)
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(emoji, style: const TextStyle(fontSize: 22)),
                                            const SizedBox(width: 8),
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 180), // 🔹 límite seguro
                                              child: Text(
                                                cat,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (rank != null || assignedFlag != null)
                                          Row(
                                            children: [
                                              if (rank != null)
                                                Text(
                                                  "#$rank",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              if (assignedFlag != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 6),
                                                  child: Text(
                                                    assignedFlag,
                                                    style: const TextStyle(
                                                        fontSize: 24),
                                                  ),
                                                ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Reset Button
                            if (vm.gameStarted || vm.currentCountry != null) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.shade400,
                                        Colors.red.shade700
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      textStyle: const TextStyle(fontSize: 18),
                                    ),
                                    onPressed: vm.restartGame,
                                    child: const Text("Reset Game"),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
                              // --- POPUP Better Choice con animación y gradiente ---
                if (vm.betterChoiceMessage != null && vm.showBetterChoicePopup)
                  Builder(
                    builder: (context) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (vm.betterChoiceMessage != null && vm.showBetterChoicePopup) {
                          CustomSnackBar.show(
                            context,
                            message: vm.betterChoiceMessage!,
                            type: SnackBarType.exotic,
                          );
                          vm.showBetterChoicePopup = false;
                        }
                      });
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GameInfoDialog(
        title: "Cómo jugar a GeoExpert",
        instructions: [
          "Visualiza las categorías de rankings, que serán los botones inferiores.",
          "Pulsa empezar a jugar y verás la bandera que representa a tu primer país.",
          "Asigna ese país a la categoría en la que creas que tiene mejor ranking internacional (cuanto más bajo, mejor).",
          "Haz lo mismo con los siguientes países, el juego acabará cuando rellenes todas las categorías.",
          "Cuanto menor sea tu puntuación acumulada mejor lo habrás hecho, podrás visualizar tu top 3 en el botón del trofeo en la parte superior derecha."
        ],
        example:
            "Ejemplo: Si el juego te muestra la bandera de Estados Unidos y tienes libre la categoría de tecnología, es buena opción asigarla ya que en ella Estados Unidos se encuentra en el Top 3.",
        imageAsset: null,
      ),
    );
  }

  void _showHighScores(BuildContext context, List<int> topScores) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "HighScores",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "🏆 High Scores",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (topScores.isEmpty)
                    const Text(
                      "No has acabado ningún juego aún",
                      style: TextStyle(fontSize: 16),
                    )
                  else
                    Column(
                      children: List.generate(topScores.length, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 500 + 100 * index),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade200,
                                Colors.deepPurple.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "#${index + 1}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "${topScores[index]} pts",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final scale = Tween<double>(begin: 0.9, end: 1.0).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }
}
