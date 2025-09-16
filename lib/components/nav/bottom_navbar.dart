import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'package:gamebible/l10n/app_localizations.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: loc.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite),
          label: loc.favorites,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: loc.profile,
        ),
      ],
    );
  }
}
