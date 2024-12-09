part of 'game_bloc.dart';

// Events
abstract class GameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeGameEvent extends GameEvent {}

class StartDragEvent extends GameEvent {
  final int row;
  final int col;
  final double dx;
  final double dy;

  StartDragEvent(this.row, this.col, this.dx, this.dy);

  @override
  List<Object?> get props => [row, col, dx, dy];
}

class UpdateDragEvent extends GameEvent {
  final int row;
  final int col;
  final double dx;
  final double dy;

  UpdateDragEvent(this.row, this.col, this.dx, this.dy);

  @override
  List<Object?> get props => [row, col, dx, dy];
}

class EndDragEvent extends GameEvent {}

class StopShakingEvent extends GameEvent {}

class ResetGameEvent extends GameEvent {}
