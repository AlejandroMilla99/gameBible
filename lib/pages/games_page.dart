import 'package:flutter/material.dart';
import 'package:gamebible/l10n/app_localizations.dart';
import 'package:gamebible/pages/games/emoji_challenge_page.dart';
import 'package:gamebible/pages/games/fast_quiz_page.dart';
import 'package:gamebible/pages/games/geoExpert/geo_expert_page.dart';
import 'package:gamebible/pages/games/never_have_i_ever_page.dart';
import 'package:gamebible/pages/games/reverse_voice_page.dart';
import 'package:gamebible/pages/games/truth_dare_page.dart';
import 'package:gamebible/pages/games/worday/wordayPage.dart';
import 'package:gamebible/pages/games/tabu_word.dart';
import '../models/game.dart';
import 'game_detail_page.dart';
import '../constants/app_spacing.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final games = [
      Game(
        title: loc.truthOrDareTitle,
        description: loc.truthOrDareDesc,
        image: AppImages.truthDare,
        play: (ctx, {dailyMode = false}) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => TruthDarePage(title: loc.truthOrDareTitle),
            ),
          );
        },
      ),
      Game(
        title: loc.neverHaveIEverTitle,
        description: loc.neverHaveIEverDesc,
        image: AppImages.neverHaveIEver,
        play: (ctx, {dailyMode = false}) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) =>
                  NeverHaveIEverPage(title: loc.neverHaveIEverTitle),
            ),
          );
        },
      ),
      Game(
        title: loc.fastQuizTitle,
        description: loc.fastQuizDesc,
        image: AppImages.quickTest,
        play: (ctx, {dailyMode = false}) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => FastQuizPage(title: loc.fastQuizTitle),
            ),
          );
        },
      ),
      Game(
        title: loc.emojiChallengeTitle,
        description: loc.emojiChallengeDesc,
        image: AppImages.emojiChallenge,
        play: (ctx, {dailyMode = false}) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) =>
                  EmojiChallengePage(title: loc.emojiChallengeTitle),
            ),
          );
        },
      ),
      Game(
        title: loc.geoExpertTitle,
        description: loc.geoExpertDesc,
        image: AppImages.geoExpert,
        hasDailyChallenge: true,
        play: (ctx, {dailyMode = false}) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => GeoExpertPage(title: loc.geoExpertTitle, isDailyMode: dailyMode),
            ),
          );
        },
      ),
      Game(
        title: loc.wordayTitle,
        description: loc.wordayDesc,
        image: AppImages.worday,
        hasDailyChallenge: true,
        play: (ctx, {dailyMode = false}) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => WordayPage(title: loc.wordayTitle, isDailyMode: dailyMode),
            ),
          );
        },
      ),
      Game(
        title: loc.tabuWordTitle,
        description: loc.tabuWordDesc,
        image: AppImages.taboo,
        play: (ctx, {dailyMode = false}) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => TabuWordPage(title: loc.tabuWordTitle),
            ),
          );
        },
      ),
      Game(
        title: loc.reverseVoice,
        description: loc.reverseVoiceDesc,
        image: AppImages.reverseVoice,
        play: (ctx, {dailyMode = false}) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ReverseVoicePage(title: loc.reverseVoice),
            ),
          );
        },
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
