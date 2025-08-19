import 'package:flutter/material.dart';

class Game {
  final String title;
  final String description;
  final String image;
  final void Function(BuildContext context) play;

  Game({
    required this.title,
    required this.description,
    required this.image,
    required this.play,
  });
}
