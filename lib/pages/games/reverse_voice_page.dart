import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import '../../constants/app_colors.dart';
import 'package:gamebible/components/dialogs/game_info_dialog.dart';
import 'package:gamebible/l10n/app_localizations.dart';

class ReverseVoicePage extends StatefulWidget {
  final String title;
  const ReverseVoicePage({super.key, required this.title});

  @override
  State<ReverseVoicePage> createState() => _ReverseVoicePageState();
}

class _ReverseVoicePageState extends State<ReverseVoicePage>
    with SingleTickerProviderStateMixin {
  final _record = AudioRecorder();
  final _player = AudioPlayer();

  bool _isRecording = false;
  bool _isReproducing = false;
  bool _greenUnlocked = true;
  bool _blueUnlocked = false;

  bool _showGreenHint = true;
  bool _showBlueHint = true;

  String? _recordedPath;
  String? _reversedPath;
  Timer? _recordingTimer;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _startOrStopRecording() async {
    if (_showGreenHint) {
      setState(() {
        _showGreenHint = false;
      });
    }

    if (_isRecording) {
      await _stopRecording();
    } else {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) return;

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/recorded.wav';

      await _record.start(
        const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000),
        path: path,
      );

      _recordingTimer?.cancel();
      _recordingTimer = Timer(const Duration(seconds: 10), () async {
        if (_isRecording) {
          await _stopRecording();
        }
      });

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final path = await _record.stop();
    setState(() {
      _isRecording = false;
      _recordedPath = path;
      _greenUnlocked = false;
      _blueUnlocked = true;
      _showBlueHint = true;
    });

    if (path != null) {
      await _reverseAudio(path);
    }
  }

  Future<void> _reverseAudio(String path) async {
    final dir = await getTemporaryDirectory();
    final outPath = '${dir.path}/reversed.wav';

    final command = "-i $path -af areverse $outPath";
    await FFmpegKit.execute(command);

    if (await File(outPath).exists()) {
      setState(() {
        _reversedPath = outPath;
      });
    }
  }

  Future<void> _playReversed() async {
    if (_showBlueHint) {
      setState(() {
        _showBlueHint = false;
      });
    }

    if (_reversedPath == null) return;
    if (_isReproducing) return;

    setState(() {
      _isReproducing = true;
    });

    await _player.play(DeviceFileSource(_reversedPath!));

    _player.onPlayerComplete.listen((_) async {
      if (_recordedPath != null && await File(_recordedPath!).exists()) {
        await File(_recordedPath!).delete();
      }
      if (_reversedPath != null && await File(_reversedPath!).exists()) {
        await File(_reversedPath!).delete();
      }

      setState(() {
        _recordedPath = null;
        _reversedPath = null;
        _blueUnlocked = false;
        _greenUnlocked = true;
        _isReproducing = false;
        _showGreenHint = true;
        _showBlueHint = false;
      });
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _record.dispose();
    _player.dispose();
    _pulseController.dispose();

    if (_recordedPath != null) {
      File(_recordedPath!).delete().ignore();
    }
    if (_reversedPath != null) {
      File(_reversedPath!).delete().ignore();
    }

    super.dispose();
  }

  Widget _animatedText(String text) {
    return ScaleTransition(
      scale: Tween(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      ),
      child: Stack(
        children: [
          // Contorno negro
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = Colors.black,
            ),
          ),
          // Texto con gradiente encima
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [Colors.white, Colors.yellowAccent, Colors.white],
                stops: const [0.2, 0.5, 0.8],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_rounded),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              color:
                  _greenUnlocked ? Colors.green.shade300 : Colors.grey.shade400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: _isRecording ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: IconButton(
                      iconSize: 80,
                      color: Colors.white,
                      onPressed: _greenUnlocked ? _startOrStopRecording : null,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_off,
                          key: ValueKey(_isRecording),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: (_greenUnlocked && _showGreenHint)
                        ? _animatedText(t.record)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              color: _blueUnlocked ? Colors.blue.shade300 : Colors.grey.shade400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: _isReproducing ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: IconButton(
                      iconSize: 80,
                      color: Colors.white,
                      onPressed: _blueUnlocked
                          ? (_isReproducing ? () {} : _playReversed)
                          : null,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                        child: Icon(
                          _isReproducing ? Icons.volume_up : Icons.volume_mute,
                          key: ValueKey(_isReproducing),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: (_blueUnlocked && _showBlueHint)
                        ? _animatedText(t.reproduce)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => GameInfoDialog(
        title: t.reverseVoiceHowToPlay,
        instructions: [
          t.reverseVoiceInstruction1,
          t.reverseVoiceInstruction2,
          t.reverseVoiceInstruction3,
          t.reverseVoiceInstruction4,
        ],
        example: t.reverseVoiceExample,
        imageAsset: null,
      ),
    );
  }
}
