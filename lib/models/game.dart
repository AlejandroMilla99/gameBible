import 'package:flutter/material.dart';

class Game {
  final String title;
  final String description;
  final String image;
  bool? hasDailyChallenge = false;
  final void Function(BuildContext ctx, {bool dailyMode}) play;
  Game({
    required this.title,
    required this.description,
    required this.image,
    this.hasDailyChallenge,
    required this.play,
  });
}
