part of 'game_bloc.dart';

// State
class GameState extends Equatable {
  final List<List<String>> letters;
  final List<Position> selectedPositions;
  final List<Offset> selectedPoints;
  final String currentWord;
  final Offset? currentDragPosition;
  final bool isCorrectWord;
  final bool isShaking;

  const GameState({
    required this.letters,
    required this.selectedPositions,
    required this.selectedPoints,
    required this.currentWord,
    this.currentDragPosition,
    this.isCorrectWord = false,
    this.isShaking = false,
  });

  GameState copyWith({
    List<List<String>>? letters,
    List<Position>? selectedPositions,
    List<Offset>? selectedPoints,
    String? currentWord,
    Offset? currentDragPosition,
    bool? isCorrectWord,
    bool? isShaking,
  }) {
    return GameState(
      letters: letters ?? this.letters,
      selectedPositions: selectedPositions ?? this.selectedPositions,
      selectedPoints: selectedPoints ?? this.selectedPoints,
      currentWord: currentWord ?? this.currentWord,
      currentDragPosition: currentDragPosition,
      isCorrectWord: isCorrectWord ?? this.isCorrectWord,
      isShaking: isShaking ?? this.isShaking,
    );
  }

  @override
  List<Object?> get props =>
      [letters, selectedPositions, selectedPoints, currentWord, currentDragPosition, isCorrectWord, isShaking];
}
