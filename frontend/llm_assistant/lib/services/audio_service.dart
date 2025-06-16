// Copyright (c) 2024 LLM Journal. All rights reserved.

import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

/// A singleton service class that handles audio playback functionality.
/// 
/// Manages the loading and playback of motivational speeches and other audio content.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  
  /// Returns the singleton instance of AudioService.
  factory AudioService() => _instance;
  
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  bool _isPlaying = false;
  bool _isLoaded = false;
  String? _currentAudioPath;

  /// Whether audio is currently playing.
  bool get isPlaying => _isPlaying;
  
  /// Whether audio has been loaded and is ready to play.
  bool get isLoaded => _isLoaded;

  /// Preloads the motivational speech audio for the past week.
  /// 
  /// Downloads and caches the audio file for immediate playback when requested.
  Future<void> preloadMotivationalSpeech() async {
    if (_isLoaded && _currentAudioPath != null) return;

    try {
      final audioData = await _apiService.getMotivationalSpeechLastWeek();
      
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/motivational_speech.mp3');
      await tempFile.writeAsBytes(audioData);
      
      _currentAudioPath = tempFile.path;
      _isLoaded = true;

      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isLoaded = false;
      _currentAudioPath = null;
      rethrow;
    }
  }

  /// Plays the preloaded motivational speech.
  /// 
  /// If the speech hasn't been preloaded, it will be loaded first.
  Future<void> playMotivationalSpeech() async {
    if (!_isLoaded) {
      await preloadMotivationalSpeech();
    }

    if (_currentAudioPath != null) {
      _isPlaying = true;
      await _audioPlayer.play(DeviceFileSource(_currentAudioPath!));
    }
  }

  /// Pauses the currently playing motivational speech.
  Future<void> pauseMotivationalSpeech() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  /// Stops the currently playing motivational speech.
  Future<void> stopMotivationalSpeech() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  /// Disposes of the audio player resources.
  void dispose() {
    _audioPlayer.dispose();
  }
} 