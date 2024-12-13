import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:word_game_bloc/blocs/game_bloc.dart';
import 'package:word_game_bloc/model/position.dart';
import 'package:word_game_bloc/services/audio_service.dart';
import 'package:word_game_bloc/services/word_placer.dart';

@GenerateMocks([WordPlacer, AudioService])
import 'game_bloc_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameBloc', () {
    late GameBloc gameBloc;
    late MockWordPlacer mockWordPlacer;
    late MockAudioService mockAudioService;
    const validWord = 'VUELTO';
    const gridSize = 4;

    setUp(() {
      mockAudioService = MockAudioService();
      mockWordPlacer = MockWordPlacer();

      // Setup mock word placer behavior
      when(mockWordPlacer.getGrid()).thenReturn(
          List.generate(gridSize, (i) => List.generate(gridSize, (j) => 'A'))
      );
      when(mockWordPlacer.reset()).thenReturn(
          List.generate(gridSize, (i) => List.generate(gridSize, (j) => 'A'))
      );

      gameBloc = GameBloc(
        wordPlacer: mockWordPlacer,
        validWord: validWord,
        gridSize: gridSize,
        audioService: mockAudioService,
      );
    });

    test('initial state is correct', () {
      expect(gameBloc.state.currentWord, '');
      expect(gameBloc.state.selectedPositions, isEmpty);
      expect(gameBloc.state.selectedPoints, isEmpty);
      expect(gameBloc.state.currentDragPosition, isNull);
      expect(gameBloc.state.isCorrectWord, isFalse);
      expect(gameBloc.state.isShaking, isFalse);
    });

    blocTest<GameBloc, GameState>(
      'emits new state on InitializeGameEvent',
      build: () => gameBloc,
      act: (bloc) => bloc.add(InitializeGameEvent()),
      expect: () => [
        isA<GameState>()
            .having((state) => state.selectedPositions, 'selectedPositions', isEmpty)
            .having((state) => state.currentWord, 'currentWord', '')
            .having((state) => state.isCorrectWord, 'isCorrectWord', false)
            .having((state) => state.isShaking, 'isShaking', false)
            .having((state) => state.currentDragPosition, 'currentDragPosition', isNull)
      ],
    );

    blocTest<GameBloc, GameState>(
      'emits new state on StartDragEvent',
      build: () => gameBloc,
      act: (bloc) => bloc.add(StartDragEvent(0, 0, 150.0, 150.0)),
      expect: () => [
        isA<GameState>()
            .having((state) => state.selectedPositions.length, 'positions length', 1)
            .having((state) => state.selectedPositions.first, 'first position', Position(0, 0))
            .having((state) => state.currentWord, 'currentWord', 'A')
            .having((state) => state.currentDragPosition, 'dragPosition', const Offset(150.0, 150.0))
      ],
    );

    blocTest<GameBloc, GameState>(
      'ignores StartDragEvent with invalid position',
      build: () => gameBloc,
      act: (bloc) => bloc.add(StartDragEvent(-1, -1, 150.0, 150.0)),
      expect: () => [],
    );

    blocTest<GameBloc, GameState>(
      'emits new state on UpdateDragEvent with new valid position',
      build: () => gameBloc,
      seed: () => GameState(
        letters: gameBloc.state.letters,
        selectedPositions: [Position(0, 0)],
        selectedPoints: const [Offset(150.0, 150.0)],
        currentWord: 'A',
        currentDragPosition: const Offset(150.0, 150.0),
      ),
      act: (bloc) => bloc.add(UpdateDragEvent(0, 1, 200.0, 150.0)),
      expect: () => [
        isA<GameState>()
            .having((state) => state.selectedPositions.length, 'positions length', 2)
            .having((state) => state.currentWord, 'currentWord', 'AA')
            .having((state) => state.currentDragPosition, 'dragPosition', const Offset(200.0, 150.0))
      ],
    );

    blocTest<GameBloc, GameState>(
      'ignores UpdateDragEvent with diagonal move',
      build: () => gameBloc,
      seed: () => GameState(
        letters: gameBloc.state.letters,
        selectedPositions: [Position(0, 0)],
        selectedPoints: const [Offset(150.0, 150.0)],
        currentWord: 'A',
        currentDragPosition: const Offset(150.0, 150.0),
      ),
      act: (bloc) => bloc.add(UpdateDragEvent(1, 1, 200.0, 200.0)),
      expect: () => [],
    );

    blocTest<GameBloc, GameState>(
      'ignores UpdateDragEvent with too far move',
      build: () => gameBloc,
      seed: () => GameState(
        letters: gameBloc.state.letters,
        selectedPositions: [Position(0, 0)],
        selectedPoints: const [Offset(150.0, 150.0)],
        currentWord: 'A',
        currentDragPosition: const Offset(150.0, 150.0),
      ),
      act: (bloc) => bloc.add(UpdateDragEvent(0, 2, 250.0, 150.0)),
      expect: () => [],
    );

    blocTest<GameBloc, GameState>(
      'emits correct states sequence on EndDragEvent with correct word',
      build: () {
        when(mockAudioService.playSuccessSound()).thenAnswer((_) async {});
        return gameBloc;
      },
      seed: () => GameState(
        letters: gameBloc.state.letters,
        selectedPositions: List.generate(validWord.length, (i) => Position(0, i)),
        selectedPoints: List.generate(validWord.length, (i) => Offset(i * 50.0, 150.0)),
        currentWord: validWord,
      ),
      act: (bloc) => bloc.add(EndDragEvent()),
      expect: () => [
        isA<GameState>()
            .having((state) => state.isCorrectWord, 'isCorrectWord', true)
            .having((state) => state.currentDragPosition, 'dragPosition', isNull)
      ],
      verify: (_) {
        verify(mockAudioService.playSuccessSound()).called(1);
      },
    );

    blocTest<GameBloc, GameState>(
      'emits correct states sequence on EndDragEvent with incorrect word',
      build: () => gameBloc,
      seed: () => GameState(
        letters: gameBloc.state.letters,
        selectedPositions: [Position(0, 0), Position(0, 1)],
        selectedPoints: const [Offset(150.0, 150.0), Offset(200.0, 150.0)],
        currentWord: 'AA',
      ),
      act: (bloc) => bloc.add(EndDragEvent()),
      expect: () => [
        isA<GameState>()
            .having((state) => state.isCorrectWord, 'isCorrectWord', false)
            .having((state) => state.currentDragPosition, 'dragPosition', isNull)
            .having((state) => state.isShaking, 'isShaking', true),
        isA<GameState>()
            .having((state) => state.isShaking, 'isShaking', false),
        isA<GameState>()
            .having((state) => state.selectedPositions, 'selectedPositions', isEmpty)
            .having((state) => state.currentWord, 'currentWord', '')
            .having((state) => state.isCorrectWord, 'isCorrectWord', false)
      ],
      wait: const Duration(milliseconds: 600),
    );

    blocTest<GameBloc, GameState>(
      'emits new grid on ResetGameEvent',
      build: () => gameBloc,
      act: (bloc) => bloc.add(ResetGameEvent()),
      expect: () => [
        isA<GameState>()
            .having((state) => state.letters, 'letters', isNotEmpty)
            .having((state) => state.selectedPositions, 'selectedPositions', isEmpty)
            .having((state) => state.currentWord, 'currentWord', '')
            .having((state) => state.isCorrectWord, 'isCorrectWord', false)
            .having((state) => state.isShaking, 'isShaking', false)
      ],
      verify: (_) {
        verify(mockWordPlacer.reset()).called(1);
      },
    );

    test('disposes audio service on close', () async {
      await gameBloc.close();
      verify(mockAudioService.dispose()).called(1);
    });
  });
}