import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:word_game_bloc/model/position.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  static const int gridSize = 4;
  final String validWord = 'VUELTO';

  final AudioPlayer _audioPlayer = AudioPlayer();


  GameBloc()
      : super(const GameState(
          letters: [
            ['A', 'K', 'O', 'E'],
            ['O', 'L', 'T', 'M'],
            ['R', 'E', 'U', 'P'],
            ['P', 'I', 'V', 'E'],
          ],
          selectedPositions: [],
          selectedPoints: [],
          currentWord: '',
        )) {
    on<InitializeGameEvent>(_onInitializeGame);
    on<StartDragEvent>(_onStartDrag);
    on<UpdateDragEvent>(_onUpdateDrag);
    on<EndDragEvent>(_onEndDrag);
    on<StopShakingEvent>(_onStopShaking);
    on<ResetGameEvent>(_onResetGame);
  }

  void _onInitializeGame(InitializeGameEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(
      selectedPositions: [],
      selectedPoints: [],
      currentWord: '',
      currentDragPosition: null,
      isCorrectWord: false,
      isShaking: false,
    ));
  }

  void _onStartDrag(StartDragEvent event, Emitter<GameState> emit) {
    final Position position = Position(event.row, event.col);
    if (event.row < 0 || event.col < 0 || event.row >= gridSize || event.col >= gridSize) {
      return;
    }

    final Offset point = Offset(event.dx, event.dy);

    emit(state.copyWith(
      selectedPositions: [position],
      selectedPoints: [point],
      currentWord: state.letters[event.row][event.col],
      currentDragPosition: point,
    ));
  }


  void _onUpdateDrag(UpdateDragEvent event, Emitter<GameState> emit) {
    final Position position = Position(event.row, event.col);
    if (event.row < 0 || event.col < 0 || event.row >= gridSize || event.col >= gridSize || state.selectedPositions.contains(position)) {
      return;
    }

    final List<Position> newPositions = [...state.selectedPositions, position];
    final List<Offset> newPoints = [...state.selectedPoints, Offset(event.dx, event.dy)];
    final String newWord = state.currentWord + state.letters[event.row][event.col];

    emit(state.copyWith(
      selectedPositions: newPositions,
      selectedPoints: newPoints,
      currentWord: newWord,
      currentDragPosition: Offset(event.dx, event.dy),
    ));
  }

  void _onEndDrag(EndDragEvent event, Emitter<GameState> emit) async {
    final bool isCorrect = validWord.contains(state.currentWord);

    emit(state.copyWith(
      currentDragPosition: null,
      isCorrectWord: isCorrect,
    ));

    if (isCorrect) {
      await _audioPlayer.play(AssetSource('success_fanfare.mp3'));
    } else if (state.currentWord.isNotEmpty) {
      emit(state.copyWith(isShaking: true));

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }

      await Future.delayed(const Duration(milliseconds: 500));

      add(StopShakingEvent());
    }
  }



  void _onStopShaking(StopShakingEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(isShaking: false));
  }

  void _onResetGame(ResetGameEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(
      selectedPositions: [],
      selectedPoints: [],
      currentWord: '',
      currentDragPosition: null,
      isCorrectWord: false,
      isShaking: false,
    ));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }

}
