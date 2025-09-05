import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_colors.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';


class NeverHaveIEverPage extends StatefulWidget {
  final String title;
  const NeverHaveIEverPage({super.key, required this.title});

  @override
  State<NeverHaveIEverPage> createState() => _NeverHaveIEverPageState();
}

class _NeverHaveIEverPageState extends State<NeverHaveIEverPage> {
  final List<String> normal = [
    "Nunca he copiado en un examen.",
    "Nunca he cantado en la ducha.",
    "Nunca me he dormido en el transporte público.",
    "Nunca he perdido un vuelo.",
  ];

  final List<String> plus18 = [
    "Nunca he tenido una cita a ciegas.",
    "Nunca he enviado un mensaje atrevido.",
    "Nunca he besado a alguien en público.",
    "Nunca he mentido sobre con quién estaba.",
  ];

  String? currentStatement;
  final _random = Random();

  void _pickNormal() {
    setState(() {
      currentStatement = normal[_random.nextInt(normal.length)];
    });
  }

  void _pick18() {
    setState(() {
      currentStatement = plus18[_random.nextInt(plus18.length)];
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: currentStatement == null
                    ? const Text(
                        "Elige Normal o +18 para comenzar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Container(
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
                        child: Text(
                          currentStatement!,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 64,
                  onPressed: _pickNormal,
                  icon: const Icon(Icons.sentiment_satisfied, color: Colors.green),
                  tooltip: "Normal",
                ),
                IconButton(
                  iconSize: 64,
                  onPressed: _pick18,
                  icon: const Icon(Icons.explicit, color: Colors.purple),
                  tooltip: "+18",
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
        title: "Cómo jugar a Yo Nunca",
        instructions: [
          "Cada jugador, por turnos, pulsa uno de los dos botones inferiores: 'Normal' o '+18'.",
          "Se mostrará en pantalla una frase que empieza por 'Nunca he...'.",
          "Todos los jugadores deben pensar si alguna vez han hecho lo que aparece en la frase.",
          "Si un jugador SÍ lo ha hecho, debe reconocerlo (por ejemplo, levantando la mano, tomando un sorbo de bebida, o como acuerde el grupo).",
          "El juego continúa mientras los jugadores quieran, alternando frases entre la categoría Normal y la +18."
        ],
        example: "Ejemplo: Si aparece la frase 'Nunca he perdido un vuelo' y un jugador sí lo ha perdido, deberá admitirlo.",
        imageAsset: null, // opcional, puedes añadir una ilustración temática
      ),
    );
  }

}
