import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  Future<void> playSuccessSound() async {
    await _audioPlayer.play(AssetSource('success_fanfare.mp3'));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}