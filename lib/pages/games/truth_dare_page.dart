import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';

enum ChallengeCategory { truth, dare }

class TruthDarePage extends StatefulWidget {
  final String title;
  const TruthDarePage({super.key, required this.title});

  @override
  State<TruthDarePage> createState() => _TruthDarePageState();
}

class _TruthDarePageState extends State<TruthDarePage> {
  List<String> truths = [];
  List<String> dares = [];

  List<String> remainingTruths = [];
  List<String> remainingDares = [];

  String? currentChallenge;
  final _random = Random();
  bool _swipeRight = true; // controla la dirección del swipe
  ChallengeCategory? _currentCategory; // para el borde de color

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final truthsString = await rootBundle.loadString("assets/data/truths.json");
    final daresString = await rootBundle.loadString("assets/data/dares.json");

    final List<dynamic> truthsData = json.decode(truthsString);
    final List<dynamic> daresData = json.decode(daresString);

    setState(() {
      truths = truthsData.cast<String>();
      dares = daresData.cast<String>();
      _resetIterationTruths();
      _resetIterationDares();
    });
  }

  void _resetIterationTruths() {
    remainingTruths = List.from(truths)..shuffle(_random);
  }

  void _resetIterationDares() {
    remainingDares = List.from(dares)..shuffle(_random);
  }

  void _pickTruth() {
    if (truths.isEmpty) return; // evitar crash si lista vacía

    setState(() {
      _swipeRight = !_swipeRight;
      _currentCategory = ChallengeCategory.truth;

      // si la lista de remaining está vacía, reiniciarla
      if (remainingTruths.isEmpty) _resetIterationTruths();

      // ahora sí removemos el primer elemento
      currentChallenge = remainingTruths.removeAt(0);
    });
  }

  void _pickDare() {
    if (dares.isEmpty) return; // evitar crash si lista vacía

    setState(() {
      _swipeRight = !_swipeRight;
      _currentCategory = ChallengeCategory.dare;

      // si la lista de remaining está vacía, reiniciarla
      if (remainingDares.isEmpty) _resetIterationDares();

      // ahora sí removemos el primer elemento
      currentChallenge = remainingDares.removeAt(0);
    });
  }

  Color _getBorderColor() {
    switch (_currentCategory) {
      case ChallengeCategory.truth:
        return Colors.blue;
      case ChallengeCategory.dare:
        return Colors.red;
      default:
        return Colors.grey;
    }
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: Offset(_swipeRight ? 1.0 : -1.0, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                  child: currentChallenge == null
                      ? const Text(
                          key: ValueKey("empty"),
                          "Elige Verdad o Reto para comenzar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Container(
                          key: ValueKey(currentChallenge),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getBorderColor(),
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            currentChallenge!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 64,
                  onPressed: _pickTruth,
                  icon: const Icon(Icons.question_answer, color: Colors.blue),
                  tooltip: "Verdad",
                ),
                IconButton(
                  iconSize: 64,
                  onPressed: _pickDare,
                  icon: const Icon(Icons.local_fire_department, color: Colors.red),
                  tooltip: "Reto",
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GameInfoDialog(
        title: "Cómo jugar a Verdad o Reto",
        instructions: [
          "Elige entre 'Verdad' o 'Reto' pulsando uno de los dos botones inferiores.",
          "Si eliges 'Verdad', deberás responder con sinceridad a la pregunta que aparezca en pantalla.",
          "Si eliges 'Reto', tendrás que realizar la acción que se te proponga.",
          "El juego continúa turnándose entre los jugadores, alternando preguntas y retos.",
          "El objetivo es divertirse, descubrir cosas nuevas y aceptar los desafíos."
        ],
        example:
            "Ejemplo: Si eliges 'Verdad', puede tocarte responder '¿Cuál ha sido tu mayor vergüenza?'. Si eliges 'Reto', puede salirte 'Imita a alguien del grupo durante 1 minuto'.",
        imageAsset: null,
      ),
    );
  }
}
