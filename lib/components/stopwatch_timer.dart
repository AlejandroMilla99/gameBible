import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gamebible/l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

enum StopwatchStatus { initial, running, paused }

class StopwatchTimer extends StatefulWidget {
  const StopwatchTimer({super.key});

  @override
  State<StopwatchTimer> createState() => _StopwatchTimerState();
}

class _StopwatchTimerState extends State<StopwatchTimer> {
  StopwatchStatus _status = StopwatchStatus.initial;
  Timer? _timer;
  int _secondsElapsed = 0;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _secondsElapsed = 0;
      _status = StopwatchStatus.initial;
    });
  }

  void _toggleTimer() {
    if (_status == StopwatchStatus.initial || _status == StopwatchStatus.paused) {
      setState(() {
        _status = StopwatchStatus.running;
      });
      _startTimer();
    } else if (_status == StopwatchStatus.running) {
      setState(() {
        _status = StopwatchStatus.paused;
      });
      _stopTimer();
    }
  }

  String get _formattedTime {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    Color toggleColor;
    String toggleText;

    switch (_status) {
      case StopwatchStatus.initial:
        toggleText = loc.startWatch;
        toggleColor = Colors.green;
        break;
      case StopwatchStatus.running:
        toggleText = loc.stop;
        toggleColor = AppColors.secondary;
        break;
      case StopwatchStatus.paused:
        toggleText = loc.resume;
        toggleColor = AppColors.primary;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formattedTime,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _resetTimer,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: Text(loc.resetTimer),
            ),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton(
              onPressed: _toggleTimer,
              style: ElevatedButton.styleFrom(backgroundColor: toggleColor, foregroundColor: Colors.white),
              child: Text(toggleText),
            ),
          ],
        ),
      ],
    );
  }
}
