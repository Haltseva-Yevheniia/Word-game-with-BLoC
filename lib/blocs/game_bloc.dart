import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:word_game_bloc/components/position_class.dart';

part 'game_event.dart';
part 'game_state.dart';

// BLoC
class GameBloc extends Bloc<GameEvent, GameState> {
  static const int gridSize = 4;
  final Set<String> validWords = {'VUELTO'};

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
    on<ResetGameEvent>(_onResetGame);
  }

  void _onInitializeGame(InitializeGameEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(
      selectedPositions: [],
      selectedPoints: [],
      currentWord: '',
      currentDragPosition: null,
      isCorrectWord: false,
    ));
  }

  void _onStartDrag(StartDragEvent event, Emitter<GameState> emit) {
    final Position position = Position(event.row, event.col);
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
    if (!state.selectedPositions.contains(position)) {
      final List<Position> newPositions = [...state.selectedPositions, position];
      final List<Offset> newPoints = [...state.selectedPoints, Offset(event.dx, event.dy)];
      final String newWord = state.currentWord + state.letters[event.row][event.col];

      emit(state.copyWith(
        selectedPositions: newPositions,
        selectedPoints: newPoints,
        currentWord: newWord,
        currentDragPosition: Offset(event.dx, event.dy),
      ));
    } else {
      emit(state.copyWith(
        currentDragPosition: Offset(event.dx, event.dy),
      ));
    }
  }

  void _onEndDrag(EndDragEvent event, Emitter<GameState> emit) {
    final bool isCorrect = validWords.contains(state.currentWord);
    emit(state.copyWith(
      currentDragPosition: null,
      isCorrectWord: isCorrect,
    ));

    if (!isCorrect) {
      add(ResetGameEvent());
    }
  }

  void _onResetGame(ResetGameEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(
      selectedPositions: [],
      selectedPoints: [],
      currentWord: '',
      currentDragPosition: null,
      isCorrectWord: false,
    ));
  }
}
