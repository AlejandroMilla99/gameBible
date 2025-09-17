import 'package:flutter/material.dart';
import 'package:gamebible/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late SharedPreferences _prefs;

  String _locale = 'es';
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  late AnimationController _btnController;
  late Animation<double> _btnAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _btnController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150), value: 1.0);
    _btnAnimation =
        CurvedAnimation(parent: _btnController, curve: Curves.easeOutBack);
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _locale = _prefs.getString('locale') ?? 'es';
      _soundEnabled = _prefs.getBool('soundEnabled') ?? true;
      _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setString('locale', _locale);
    await _prefs.setBool('soundEnabled', _soundEnabled);
    await _prefs.setBool('notificationsEnabled', _notificationsEnabled);

    JuegosConAmigosApp.of(context)?.setLocale(Locale(_locale));

    _btnController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _resetSettings() async {
    _btnController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() {
      _locale = 'es';
      _soundEnabled = true;
      _notificationsEnabled = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.language,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _locale,
                        isExpanded: true,
                        alignment: AlignmentDirectional.centerStart, // Fuerza despliegue hacia abajo
                        items: [
                          DropdownMenuItem(
                            value: 'es',
                            child: Row(
                              children: [
                                const Text('🇪🇸 '),
                                Text(loc.spanish),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Row(
                              children: [
                                const Text('🇬🇧 '),
                                Text(loc.english),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _locale = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(loc.sound),
                    value: _soundEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: Text(loc.notifications),
                    value: _notificationsEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ScaleTransition(
                  scale: _btnAnimation,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: AppSpacing.sm),
                    ),
                    onPressed: _resetSettings,
                    child: Text(loc.reset),
                  ),
                ),
                ScaleTransition(
                  scale: _btnAnimation,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: AppSpacing.sm),
                    ),
                    onPressed: _saveSettings,
                    child: Text(loc.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
