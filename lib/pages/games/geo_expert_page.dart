import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamebible/constants/app_colors.dart';
import 'geo_expert_viewModel.dart';

class GeoExpertPage extends StatefulWidget {
  const GeoExpertPage({super.key, required this.title});
  final String title;

  @override
  State<GeoExpertPage> createState() => _GeoExpertPageState();
}

class _GeoExpertPageState extends State<GeoExpertPage> {
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
                  icon: const Icon(Icons.emoji_events),
                  onPressed: () => _showHighScores(context, vm.topScores),
                ),
              ],
            ),
            body: Column(
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
                    itemCount: vm.categories.length + 1, // +1 para el botón Reset
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index < vm.categories.length) {
                        final cat = vm.categories[index];
                        final rank = vm.assignedRanks[cat];
                        final assignedFlag = vm.assignedCountries[cat]?.flag;
                        final emoji = vm.categoryEmojis[cat] ?? "🔹";

                        final enabled = (vm.currentCountry != null && rank == null && !vm.isRolling);

                        // Colores del gradiente según ranking
                        List<Color> gradientColors = [Colors.grey.shade700, Colors.grey.shade400];
                        if (rank != null) {
                          if (rank <= 10) {
                            gradientColors = [Colors.green.shade300, Colors.green.shade600];
                          } else if (rank > 10 && rank <= 30) {
                            gradientColors = [Colors.orange.shade300, Colors.orange.shade600];
                          } else if (rank > 30) {
                            gradientColors = [Colors.red.shade300, Colors.red.shade600];
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
                              onTap: enabled ? () => vm.assignToCategory(cat) : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Parte izquierda: emoji + categoría
                                    Row(
                                      children: [
                                        Text(emoji, style: const TextStyle(fontSize: 22)),
                                        const SizedBox(width: 8),
                                        Text(
                                          cat,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Parte derecha: ranking y bandera si asignado
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
                                              padding: const EdgeInsets.only(left: 6),
                                              child: Text(
                                                assignedFlag,
                                                style: const TextStyle(fontSize: 24),
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
                        // Botón Reset debajo de la última categoría
                        if (vm.gameStarted || vm.currentCountry != null) {
                          return Padding(
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
                                  padding: const EdgeInsets.symmetric(vertical: 16),
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
          );
        },
      ),
    );
  }

  void _showHighScores(BuildContext context, List<int> topScores) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
  }
}
