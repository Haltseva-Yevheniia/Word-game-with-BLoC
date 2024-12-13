import 'package:mockito/mockito.dart';
import 'package:word_game_bloc/services/audio_service.dart';

class MockAudioService extends Mock implements AudioService {
  @override
  Future<void> playSuccessSound() async {}

  @override
  Future<void> dispose() async {}
}
