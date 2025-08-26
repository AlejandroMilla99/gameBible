import 'package:flutter/material.dart';
import 'package:gamebible/constants/app_colors.dart';

/// Botón personalizado para las categorías del juego Geo.
/// - Muestra un emoji a la izquierda (icono de la categoría)
/// - El nombre de la categoría (y el ranking si está asignado)
/// - A la derecha, la bandera del país asignado (si aplica)
/// - Se estira a todo el ancho con esquinas redondeadas
class GeoButton extends StatelessWidget {
  final String category;
  final String emoji;
  final int? assignedRank;
  final String? assignedFlag;
  final bool enabled;
  final VoidCallback? onPressed;

  const GeoButton({
    super.key,
    required this.category,
    required this.emoji,
    required this.assignedRank,
    required this.assignedFlag,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAssigned = assignedRank != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? AppColors.primary
              : Colors.grey, // mantener colores enabled/disabled
          disabledBackgroundColor: Colors.grey,
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            // Emoji de categoría (izquierda)
            Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 12),

            // Texto central: "Category" o "Category: rank"
            Expanded(
              child: Text(
                isAssigned ? '$category: ${assignedRank!}' : category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Bandera del país asignado (derecha)
            if (isAssigned && assignedFlag != null) ...[
              const SizedBox(width: 12),
              Text(
                assignedFlag!,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
