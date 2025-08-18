import 'package:flutter/material.dart';
import '../components/layout/base_scaffold.dart';
import 'games_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      titles: const [
        "Juegos con Amigos",
        "Favoritos",
        "Perfil",
      ],
      pages: const [
        GamesPage(),
        FavoritesPage(),
        ProfilePage(),
      ],
      actions: [
        // 🔎 Acciones para GamesPage
        [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Buscar juegos")),
              );
            },
          ),
        ],

        // ❤️ Acciones para FavoritesPage
        [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // TODO: Clear favorites
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Favoritos eliminados")),
              );
            },
          ),
        ],

        // ⚙️ Acciones para ProfilePage
        [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Abrir configuración")),
              );
            },
          ),
        ],
      ],
    );
  }
}
