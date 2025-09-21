import 'package:flutter/material.dart';

/// Types of snackbar
enum SnackBarType { info, warning, error, exotic }

/// Custom snackbar that slides from bottom, stays for 2s and fades away.
/// Ensures only one snackbar is visible at a time.
class CustomSnackBar {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    IconData? customIcon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);

    // ✅ Remove previous snackbar if still visible
    _currentEntry?.remove();
    _currentEntry = null;

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _SnackBarWidget(
          message: message,
          type: type,
          customIcon: customIcon,
          duration: duration,
          onDismissed: () {
            overlayEntry.remove();
            if (_currentEntry == overlayEntry) {
              _currentEntry = null;
            }
          },
        );
      },
    );

    _currentEntry = overlayEntry;
    overlay.insert(overlayEntry);
  }
}

class _SnackBarWidget extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final IconData? customIcon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _SnackBarWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.customIcon,
  });

  @override
  State<_SnackBarWidget> createState() => _SnackBarWidgetState();
}

class _SnackBarWidgetState extends State<_SnackBarWidget>
    with TickerProviderStateMixin {
  late final AnimationController slideController;
  late final AnimationController fadeController;
  late final Animation<Offset> slideAnimation;
  late final Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // from bottom
      end: const Offset(0, -0.2), // up to 1/5 of screen
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.easeOut,
    ));

    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    );

    // start animation
    slideController.forward();

    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await fadeController.forward();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    slideController.dispose();
    fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (gradient, icon) = _getStyle(widget.type);

    // 🔹 Cambio imprescindible: envolver Positioned en un Stack
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: ReverseAnimation(fadeAnimation),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: gradient,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 320,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                                color: widget.type == SnackBarType.warning
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          widget.customIcon ?? icon,
                          color: widget.type == SnackBarType.warning
                              ? Colors.black
                              : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  (LinearGradient, IconData) _getStyle(SnackBarType type) {
    switch (type) {
      case SnackBarType.error:
        return (
          const LinearGradient(
            colors: [Colors.redAccent, Colors.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          Icons.error
        );
      case SnackBarType.warning:
        return (
          const LinearGradient(
            colors: [Color.fromARGB(255, 239, 243, 18), Color.fromARGB(255, 229, 172, 3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          Icons.warning
        );
      case SnackBarType.info:
      // ignore: unreachable_switch_default
      case SnackBarType.exotic:
        return (
          const LinearGradient(
            colors: [Color.fromARGB(255, 194, 87, 189), Color.fromARGB(255, 162, 31, 136)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          Icons.info
        );
      default:
        return (
          const LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          Icons.info
        );
    }
  }
}
