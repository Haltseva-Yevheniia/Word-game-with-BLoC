import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game_bloc/blocs/game_bloc.dart';
import 'package:word_game_bloc/components/line_painter.dart';
import 'package:word_game_bloc/model/position.dart';
import 'package:word_game_bloc/widgets/letter_cell.dart';

const double boxSize = 300.0;

class WordGameScreen extends StatelessWidget {
  const WordGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(InitializeGameEvent()),
      child: _WordGameView(),
    );
  }
}

class _WordGameView extends StatelessWidget {
  final GlobalKey _gridKey = GlobalKey();

  _WordGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Game'),
        centerTitle: true,
      ),
      backgroundColor: Colors.greenAccent,
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current Word: ${state.currentWord}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: boxSize,
                  height: boxSize,
                  child: GestureDetector(
                    onPanStart: (details) => _handleDragStart(context, details),
                    onPanUpdate: (details) => _handleDragUpdate(context, details),
                    onPanEnd: (_) => context.read<GameBloc>().add(EndDragEvent()),
                    child: Stack(
                      key: _gridKey,
                      children: [
                        // Background lines
                        Positioned.fill(
                          child: CustomPaint(
                            painter: LinePainter(
                              points: state.selectedPoints,
                              currentDragPosition: state.currentDragPosition,
                            ),
                          ),
                        ),
                        // Grid
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: GameBloc.gridSize,
                          ),
                          itemCount: GameBloc.gridSize * GameBloc.gridSize,
                          itemBuilder: (context, index) {
                            final row = index ~/ GameBloc.gridSize;
                            final col = index % GameBloc.gridSize;
                            final position = Position(row, col);
                            final isSelected = state.selectedPositions.contains(position);

                            return LetterCell(
                              letter: state.letters[row][col],
                              isSelected: isSelected,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<GameBloc>().add(ResetGameEvent()),
                child: const Text('Reset Grid'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleDragStart(BuildContext context, DragStartDetails details) {
    if (_gridKey.currentContext == null || _gridKey.currentContext?.mounted == false) {
      return;
    }
    final RenderBox box = _gridKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    const cellSize = boxSize / GameBloc.gridSize;
    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();

    if (row >= 0 && row < GameBloc.gridSize && col >= 0 && col < GameBloc.gridSize) {
      context.read<GameBloc>().add(StartDragEvent(
            row,
            col,
            (col * cellSize) + (cellSize / 2),
            (row * cellSize) + (cellSize / 2),
          ));
    }
  }

  void _handleDragUpdate(BuildContext context, DragUpdateDetails details) {
    if (_gridKey.currentContext == null || _gridKey.currentContext?.mounted == false) {
      return;
    }
    final RenderBox box = _gridKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    const cellSize = boxSize / GameBloc.gridSize;
    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();

    if (row >= 0 && row < GameBloc.gridSize && col >= 0 && col < GameBloc.gridSize) {
      context.read<GameBloc>().add(UpdateDragEvent(
            row,
            col,
            (col * cellSize) + (cellSize / 2),
            (row * cellSize) + (cellSize / 2),
          ));
    }
  }
}
