import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';
import 'package:gamebible/components/stopwatch_timer.dart';

class TabuWordPage extends StatefulWidget {
  final String title;
  const TabuWordPage({super.key, required this.title});

  @override
  State<TabuWordPage> createState() => _TabuWordPageState();
}

class _TabuWordPageState extends State<TabuWordPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allCards = []; // todas las cartas cargadas del JSON
  List<Map<String, dynamic>> availableCards = []; // cartas que quedan por usar
  Map<String, dynamic>? currentCard;
  int correctCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final String response =
        await rootBundle.loadString('assets/data/tabu.json');
    final List<dynamic> data = jsonDecode(response);
    setState(() {
      allCards = data.map((e) => Map<String, dynamic>.from(e)).toList();
      availableCards = List.from(allCards); // copia inicial
      availableCards.shuffle(); // barajamos al inicio
    });
  }

  void _pickCard({bool increment = false}) {
    if (availableCards.isEmpty) {
      // si se acaban, reiniciamos y volvemos a barajar
      availableCards = List.from(allCards);
      availableCards.shuffle();
    }
    setState(() {
      currentCard = availableCards.removeAt(0); // siempre saca la primera
      if (increment) correctCount++;
    });
  }

  void _resetCorrectCount() {
    setState(() {
      correctCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: allCards.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ));
                          return SlideTransition(
                            position: offsetAnimation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: currentCard == null
                            ? const Text(
                                "Pulsa el botón para comenzar",
                                key: ValueKey("empty"),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                                textAlign: TextAlign.center,
                              )
                            : Container(
                                key: ValueKey(currentCard!["word"]),
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentCard!["word"],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Palabras prohibidas:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: (currentCard!["forbidden"]
                                              as List<dynamic>)
                                          .map((word) => Chip(
                                                label: Text(word.toString()),
                                                backgroundColor: Colors.red[100],
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),

                  /// --- Botones dinámicos ---
                  if (currentCard == null) ...[
                    ElevatedButton(
                      onPressed: () => _pickCard(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                      ),
                      child: const Text(
                        "Empezar",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickCard(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                          ),
                          child: const Text("Descartar",
                              style: TextStyle(fontSize: 16)),
                        ),
                        ElevatedButton(
                          onPressed: () => _pickCard(increment: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                          ),
                          child: const Text("Acierto",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  /// --- Contador de aciertos con reset ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Aciertos: $correctCount",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh,
                            color: AppColors.secondary),
                        onPressed: _resetCorrectCount,
                      ),
                    ],
                  ),

                  /// --- Cronómetro en parte inferior ---
                  const SizedBox(height: AppSpacing.sm),
                  const StopwatchTimer(),
                ],
              ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GameInfoDialog(
        title: "Cómo jugar a Palabra tabú",
        instructions: [
          "Pulsa el botón 'Empezar' para obtener una palabra.",
          "Se mostrará en pantalla una palabra principal junto con una lista de palabras prohibidas.",
          "El jugador debe describir la palabra principal sin mencionar ninguna de las prohibidas.",
          "El resto del grupo debe intentar adivinar de qué palabra se trata.",
          "Si el jugador dice una palabra prohibida, pierde el turno.",
        ],
        example:
            "Ejemplo: Si aparece la palabra 'Perro' y las prohibidas son 'Animal', 'Ladrar', 'Mascota' y 'Gato', deberás describirlo diciendo algo como 'un ser vivo que suele acompañar a las personas en casa'.",
        imageAsset: null,
      ),
    );
  }
}
