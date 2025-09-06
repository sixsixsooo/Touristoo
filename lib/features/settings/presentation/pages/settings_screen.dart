import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/game_models.dart';
import '../../../core/services/data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  GameSettings _settings = const GameSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await DataService.instance.getSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      await DataService.instance.saveSettings(_settings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки сохранены'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection(
                    'Звук и музыка',
                    [
                      _buildSwitchTile(
                        'Звук',
                        'Включить звуковые эффекты',
                        _settings.soundEnabled,
                        (value) => setState(() {
                          _settings = _settings.copyWith(soundEnabled: value);
                        }),
                        Icons.volume_up,
                      ),
                      _buildSwitchTile(
                        'Музыка',
                        'Включить фоновую музыку',
                        _settings.musicEnabled,
                        (value) => setState(() {
                          _settings = _settings.copyWith(musicEnabled: value);
                        }),
                        Icons.music_note,
                      ),
                      _buildSwitchTile(
                        'Вибрация',
                        'Включить вибрацию',
                        _settings.vibrationEnabled,
                        (value) => setState(() {
                          _settings = _settings.copyWith(vibrationEnabled: value);
                        }),
                        Icons.vibration,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Графика',
                    [
                      _buildSliderTile(
                        'Громкость звука',
                        _settings.soundVolume,
                        (value) => setState(() {
                          _settings = _settings.copyWith(soundVolume: value);
                        }),
                        Icons.volume_up,
                      ),
                      _buildSliderTile(
                        'Громкость музыки',
                        _settings.musicVolume,
                        (value) => setState(() {
                          _settings = _settings.copyWith(musicVolume: value);
                        }),
                        Icons.music_note,
                      ),
                      _buildDropdownTile(
                        'Качество графики',
                        _settings.graphicsQuality,
                        ['low', 'medium', 'high'],
                        (value) => setState(() {
                          _settings = _settings.copyWith(graphicsQuality: value);
                        }),
                        Icons.high_quality,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Управление',
                    [
                      _buildSliderTile(
                        'Чувствительность',
                        _settings.controlSensitivity,
                        (value) => setState(() {
                          _settings = _settings.copyWith(controlSensitivity: value);
                        }),
                        Icons.touch_app,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Отладка',
                    [
                      _buildSwitchTile(
                        'Показывать FPS',
                        'Отображать счетчик кадров',
                        _settings.showFPS,
                        (value) => setState(() {
                          _settings = _settings.copyWith(showFPS: value);
                        }),
                        Icons.speed,
                      ),
                      _buildSwitchTile(
                        'Отладочная информация',
                        'Показывать отладочную информацию',
                        _settings.showDebugInfo,
                        (value) => setState(() {
                          _settings = _settings.copyWith(showDebugInfo: value);
                        }),
                        Icons.bug_report,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'О приложении',
                    [
                      _buildInfoTile(
                        'Версия',
                        '1.0.0',
                        Icons.info,
                      ),
                      _buildInfoTile(
                        'Разработчик',
                        'Touristoo Team',
                        Icons.person,
                      ),
                      _buildInfoTile(
                        'Платформа',
                        'RuStore',
                        Icons.store,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    ValueChanged<double> onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Slider(
        value: value,
        onChanged: onChanged,
        min: 0.0,
        max: 1.0,
        activeColor: const Color(0xFF4CAF50),
        inactiveColor: Colors.white.withOpacity(0.3),
      ),
      trailing: Text(
        '${(value * 100).round()}%',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option.toUpperCase(),
              style: const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        dropdownColor: Colors.white,
        underline: Container(),
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.white.withOpacity(0.8)),
      ),
    );
  }
}
