import 'package:flutter/material.dart';
import '../models/game.dart';
import 'game_detail_page.dart';
import '../constants/app_spacing.dart';
import '../constants/app_colors.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      Game(
        title: "Verdad o Reto",
        description: "Un clásico para animar cualquier reunión.",
        image: "assets/images/truth_dare.png",
      ),
      Game(
        title: "Yo Nunca",
        description: "Revela secretos con tus amigos.",
        image: "assets/images/never_have_i_ever.png",
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: games.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final game = games[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GameDetailPage(game: game)),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(game.image),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    game.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
