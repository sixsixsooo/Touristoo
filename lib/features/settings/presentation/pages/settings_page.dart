import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/game_providers.dart';
import '../../../../core/services/audio_service.dart';
import '../widgets/settings_section_widget.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final audioService = ref.read(audioServiceProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        audioService.playButtonSound();
                        context.go('/home');
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Audio Settings
                      SettingsSectionWidget(
                        title: 'Audio',
                        children: [
                          _buildSwitchTile(
                            context,
                            title: 'Sound Effects',
                            subtitle: 'Enable game sound effects',
                            value: settings.soundEnabled,
                            onChanged: (value) {
                              audioService.playButtonSound();
                              ref.read(settingsProvider.notifier).updateSoundEnabled(value);
                            },
                          ),
                          _buildSwitchTile(
                            context,
                            title: 'Background Music',
                            subtitle: 'Enable background music',
                            value: settings.musicEnabled,
                            onChanged: (value) {
                              audioService.playButtonSound();
                              ref.read(settingsProvider.notifier).updateMusicEnabled(value);
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Game Settings
                      SettingsSectionWidget(
                        title: 'Game',
                        children: [
                          _buildSliderTile(
                            context,
                            title: 'Controls Sensitivity',
                            subtitle: 'Adjust touch sensitivity',
                            value: settings.controlsSensitivity,
                            min: 0.5,
                            max: 2.0,
                            onChanged: (value) {
                              ref.read(settingsProvider.notifier).updateControlsSensitivity(value);
                            },
                          ),
                          _buildDropdownTile(
                            context,
                            title: 'Graphics Quality',
                            subtitle: 'Adjust visual quality',
                            value: settings.graphicsQuality,
                            items: GraphicsQuality.values,
                            onChanged: (value) {
                              audioService.playButtonSound();
                              ref.read(settingsProvider.notifier).updateGraphicsQuality(value);
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // System Settings
                      SettingsSectionWidget(
                        title: 'System',
                        children: [
                          _buildSwitchTile(
                            context,
                            title: 'Vibration',
                            subtitle: 'Enable haptic feedback',
                            value: settings.vibrationEnabled,
                            onChanged: (value) {
                              audioService.playButtonSound();
                              ref.read(settingsProvider.notifier).updateVibrationEnabled(value);
                            },
                          ),
                          _buildListTile(
                            context,
                            title: 'About',
                            subtitle: 'App version and info',
                            icon: Icons.info,
                            onTap: () {
                              audioService.playButtonSound();
                              _showAboutDialog(context);
                            },
                          ),
                          _buildListTile(
                            context,
                            title: 'Privacy Policy',
                            subtitle: 'Read our privacy policy',
                            icon: Icons.privacy_tip,
                            onTap: () {
                              audioService.playButtonSound();
                              // TODO: Open privacy policy
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Danger Zone
                      SettingsSectionWidget(
                        title: 'Danger Zone',
                        children: [
                          _buildListTile(
                            context,
                            title: 'Reset Game Data',
                            subtitle: 'Clear all progress and start over',
                            icon: Icons.refresh,
                            textColor: Colors.red,
                            onTap: () {
                              audioService.playButtonSound();
                              _showResetDialog(context, ref);
                            },
                          ),
                        ],
                      ),
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

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF4A90E2),
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: const Color(0xFF4A90E2),
            inactiveColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile<T>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required T value,
    required List<T> items,
    required Function(T) onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
        ),
      ),
      trailing: DropdownButton<T>(
        value: value,
        onChanged: (T? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        dropdownColor: const Color(0xFF1A1A2E),
        style: const TextStyle(color: Colors.white),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString().split('.').last.toUpperCase()),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.white70,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: textColor ?? Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white70,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Touristoo Runner',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.sports_esports,
        size: 48,
        color: Color(0xFF4A90E2),
      ),
      children: [
        const Text('A 3D endless runner game for RuStore.'),
        const SizedBox(height: 16),
        const Text('Built with Flutter and powered by Yandex Cloud.'),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Reset Game Data'),
        content: const Text(
          'This will permanently delete all your progress, including scores, coins, and unlocked items. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement reset functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
