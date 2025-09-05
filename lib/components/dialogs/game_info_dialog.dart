import 'package:flutter/material.dart';

class GameInfoDialog extends StatelessWidget {
  final String title;
  final List<String> instructions;
  final String? example;
  final String? imageAsset;

  const GameInfoDialog({
    super.key,
    required this.title,
    required this.instructions,
    this.example,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: Colors.transparent,
      child: _AnimatedDialogContent(
        title: title,
        instructions: instructions,
        example: example,
        imageAsset: imageAsset,
      ),
    );
  }
}

class _AnimatedDialogContent extends StatefulWidget {
  final String title;
  final List<String> instructions;
  final String? example;
  final String? imageAsset;

  const _AnimatedDialogContent({
    required this.title,
    required this.instructions,
    this.example,
    this.imageAsset,
  });

  @override
  State<_AnimatedDialogContent> createState() => _AnimatedDialogContentState();
}

class _AnimatedDialogContentState extends State<_AnimatedDialogContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dialogHeight = MediaQuery.of(context).size.height * 0.8;

    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          height: dialogHeight,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header con título + botón de cerrar
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(),

              // Contenido scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (widget.imageAsset != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              widget.imageAsset!,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Instrucciones
                      ...widget.instructions.map(
                        (step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  step,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (widget.example != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb,
                                  color: Colors.amber, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.example!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
