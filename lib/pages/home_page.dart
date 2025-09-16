import 'package:flutter/material.dart';
import 'package:gamebible/l10n/app_localizations.dart';
import '../components/layout/base_scaffold.dart';
import 'games_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BaseScaffold(
      titles: [
        loc.friendsGames,
        loc.favorites,
        loc.profile,
      ],
      pages: const [
        GamesPage(),
        FavoritesPage(),
        ProfilePage(),
      ],
      actions: [
        [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.searchGames)),
              );
            },
          ),
        ],
        [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.favoritesCleared)),
              );
            },
          ),
        ],
        [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.openSettings)),
              );
            },
          ),
        ],
      ],
    );
  }
}
