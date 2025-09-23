import 'package:flutter/material.dart';

enum LoaderType { geoExpert, wordDay }

class Loader extends StatefulWidget {
  final LoaderType? type;
  const Loader({super.key, this.type});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _color1 = ColorTween(
      begin: const Color.fromARGB(255, 58, 158, 183),
      end: const Color.fromARGB(255, 255, 0, 255),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _color2 = ColorTween(
      begin: const Color.fromARGB(255, 58, 158, 183),
      end: const Color.fromARGB(255, 255, 0, 255),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.type) {
      case LoaderType.geoExpert:
        return Icons.public;
      case LoaderType.wordDay:
        return Icons.text_fields;
      default:
        return Icons.autorenew;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();
    return ScaleTransition(
      scale: _scale,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.1416, // rotación completa continua
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    _color1.value ?? const Color.fromARGB(255, 58, 158, 183),
                    _color2.value ?? const Color.fromARGB(255, 255, 0, 255)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Icon(
                icon,
                size: 70,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
