import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:word_game_bloc/blocs/game_bloc.dart';
import 'package:word_game_bloc/model/position.dart';

void main() {
  group('GameBloc', () {
    late GameBloc gameBloc;

    setUp(() {
      gameBloc = GameBloc(validWord: 'word', gridSize: 4);
    });

    test('initial state is correct', () {
      expect(gameBloc.state.currentWord, '');
      expect(gameBloc.state.selectedPositions, isEmpty);
      expect(gameBloc.state.selectedPoints, isEmpty);
      expect(gameBloc.state.currentDragPosition, isNull);
      expect(gameBloc.state.isCorrectWord, isFalse);
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
      'emits new state on UpdateDragEvent with new position',
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
            .having((state) => state.currentWord, 'currentWord', 'AK')
      ],
    );

    blocTest<GameBloc, GameState>(
      'emits correct state on EndDragEvent with valid word',
      build: () => gameBloc,
      seed: () => GameState(
        letters: gameBloc.state.letters,
        selectedPositions: [
          Position(0, 2),
          Position(1, 2),
          Position(2, 2),
          Position(2, 1),
          Position(1, 1),
          Position(0, 2),
        ],
        selectedPoints: const [
          Offset(150.0, 150.0),
          Offset(200.0, 150.0),
          Offset(250.0, 150.0),
          Offset(250.0, 200.0),
          Offset(200.0, 200.0),
          Offset(150.0, 200.0),
        ],
        currentWord: 'VUELTO',
      ),
      act: (bloc) => bloc.add(EndDragEvent()),
      expect: () => [
        isA<GameState>()
            .having((state) => state.isCorrectWord, 'isCorrectWord', true)
            .having((state) => state.currentDragPosition, 'dragPosition', isNull)
      ],
    );

    blocTest<GameBloc, GameState>(
      'emits reset state on EndDragEvent with invalid word',
      build: () => gameBloc,
      seed: () => GameState(
        letters: gameBloc.state.letters,
        selectedPositions: [Position(0, 0), Position(0, 1)],
        selectedPoints: const [Offset(150.0, 150.0), Offset(200.0, 150.0)],
        currentWord: 'AK',
      ),
      act: (bloc) => bloc.add(EndDragEvent()),
      expect: () => [
        isA<GameState>()
            .having((state) => state.isCorrectWord, 'isCorrectWord', false)
            .having((state) => state.currentDragPosition, 'dragPosition', isNull),
      ],
    );

    blocTest<GameBloc, GameState>(
      'emits reset state on ResetGameEvent',
      build: () => gameBloc,
      seed: () => GameState(
        letters: gameBloc.state.letters,
        selectedPositions: [Position(0, 0)],
        selectedPoints: const [Offset(150.0, 150.0)],
        currentWord: 'A',
        isCorrectWord: true,
      ),
      act: (bloc) => bloc.add(ResetGameEvent()),
      expect: () => [
        isA<GameState>()
            .having((state) => state.selectedPositions, 'selectedPositions', isEmpty)
            .having((state) => state.currentWord, 'currentWord', '')
            .having((state) => state.isCorrectWord, 'isCorrectWord', false)
      ],
    );
  });
}
