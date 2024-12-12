import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:word_game_bloc/model/position.dart';
import 'package:word_game_bloc/model/word_placement.dart';
import 'package:word_game_bloc/services/audio_service.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final int gridSize;
  final String validWord;
  final AudioService _audioService = AudioService();

  GameBloc({
    required this.validWord,
    required this.gridSize,
  }) : super(GameState(
          letters: WordPlacement(validWord.toUpperCase(), gridSize).generateGrid(),
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
    final Position newPosition = Position(event.row, event.col);

    if (!_isValidPosition(newPosition) || state.selectedPositions.contains(newPosition)) {
      return;
    }

    final List<Position> newPositions = [...state.selectedPositions, newPosition];

    if (!WordPlacement(validWord, gridSize).arePositionsConnected(newPositions)) {
      return;
    }

    if (state.selectedPositions.isNotEmpty) {
      final lastPosition = state.selectedPositions.last;

      final rowDiff = (event.row - lastPosition.row).abs();
      final colDiff = (event.col - lastPosition.col).abs();

      final isDiagonalMove = rowDiff > 0 && colDiff > 0;

      final isTooFar = rowDiff > 1 || colDiff > 1;

      if (isDiagonalMove || isTooFar) {
        return;
      }
    }

    final List<Offset> newPoints = [...state.selectedPoints, Offset(event.dx, event.dy)];
    final String newWord = state.currentWord + state.letters[event.row][event.col];

    emit(state.copyWith(
      selectedPositions: newPositions,
      selectedPoints: newPoints,
      currentWord: newWord,
      currentDragPosition: Offset(event.dx, event.dy),
    ));
  }

  bool _isValidPosition(Position pos) {
    return pos.row >= 0 && pos.row < gridSize && pos.col >= 0 && pos.col < gridSize;
  }

  void _onEndDrag(EndDragEvent event, Emitter<GameState> emit) async {
    final bool isCorrect = validWord == (state.currentWord);

    emit(state.copyWith(
      currentDragPosition: null,
      isCorrectWord: isCorrect,
    ));

    if (isCorrect) {
      await _audioService.playSuccessSound();
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
    add(ResetGameEvent());
  }

  void _onResetGame(ResetGameEvent event, Emitter<GameState> emit) {
    final wordPlacement = WordPlacement(validWord.toUpperCase(), gridSize);
    final newGrid = wordPlacement.generateGrid();
    emit(state.copyWith(
      letters: newGrid,
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
    _audioService.dispose();
    return super.close();
  }
}
