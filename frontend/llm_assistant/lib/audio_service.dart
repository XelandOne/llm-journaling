import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  bool _isPlaying = false;
  bool _isLoaded = false;
  String? _currentAudioPath;

  bool get isPlaying => _isPlaying;
  bool get isLoaded => _isLoaded;

  Future<void> preloadMotivationalSpeech() async {
    if (_isLoaded && _currentAudioPath != null) return;

    try {
      // Get the audio data
      final audioData = await _apiService.getMotivationalSpeechLastWeek();
      
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/motivational_speech.mp3');
      await tempFile.writeAsBytes(audioData);
      
      _currentAudioPath = tempFile.path;
      _isLoaded = true;

      // Set up completion listener
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isLoaded = false;
      _currentAudioPath = null;
      rethrow;
    }
  }

  Future<void> playMotivationalSpeech() async {
    if (!_isLoaded) {
      await preloadMotivationalSpeech();
    }

    if (_currentAudioPath != null) {
      _isPlaying = true;
      await _audioPlayer.play(DeviceFileSource(_currentAudioPath!));
    }
  }

  Future<void> pauseMotivationalSpeech() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  Future<void> stopMotivationalSpeech() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  void dispose() {
    _audioPlayer.dispose();
  }
} 