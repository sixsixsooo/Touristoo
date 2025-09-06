import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _isInitialized = false;
  double _masterVolume = AppConfig.masterVolume;
  double _musicVolume = AppConfig.musicVolume;
  double _sfxVolume = AppConfig.sfxVolume;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    
    _isInitialized = true;
  }

  // Master Volume Control
  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    await _updateMusicVolume();
    await _updateSfxVolume();
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _updateMusicVolume();
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _updateSfxVolume();
  }

  Future<void> _updateMusicVolume() async {
    final effectiveVolume = _masterVolume * _musicVolume;
    await _musicPlayer.setVolume(effectiveVolume);
  }

  Future<void> _updateSfxVolume() async {
    final effectiveVolume = _masterVolume * _sfxVolume;
    await _sfxPlayer.setVolume(effectiveVolume);
  }

  // Music Control
  Future<void> playMusic(String assetPath) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing music: $e');
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    await _musicPlayer.resume();
  }

  // SFX Control
  Future<void> playSfx(String assetPath) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  // Game Sounds
  Future<void> playCoinSound() async {
    await playSfx('sounds/coin.wav');
  }

  Future<void> playJumpSound() async {
    await playSfx('sounds/jump.wav');
  }

  Future<void> playSlideSound() async {
    await playSfx('sounds/slide.wav');
  }

  Future<void> playCollisionSound() async {
    await playSfx('sounds/collision.wav');
  }

  Future<void> playPowerUpSound() async {
    await playSfx('sounds/powerup.wav');
  }

  Future<void> playGameOverSound() async {
    await playSfx('sounds/game_over.wav');
  }

  Future<void> playButtonSound() async {
    await playSfx('sounds/button.wav');
  }

  Future<void> playLevelUpSound() async {
    await playSfx('sounds/level_up.wav');
  }

  // Dispose
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
