import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game_bloc/blocs/game_bloc.dart';
import 'package:word_game_bloc/constants.dart';
import 'package:word_game_bloc/model/position.dart';
import 'package:word_game_bloc/ui/components/line_painter.dart';
import 'package:word_game_bloc/ui/widgets/letter_cell.dart';

typedef DragEventCreator = GameEvent Function(int row, int col, double dx, double dy);

class WordGameScreen extends StatelessWidget {
  final String word;
  final int gridSize;

  const WordGameScreen({
    super.key,
    required this.word,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
        validWord: word,
        gridSize: gridSize,
      )..add(InitializeGameEvent()),
      child: _WordGameView(gridSize: gridSize),
    );
  }
}

class _WordGameView extends StatefulWidget {
  final int gridSize;

  const _WordGameView({required this.gridSize});

  @override
  State<_WordGameView> createState() => _WordGameViewState();
}

class _WordGameViewState extends State<_WordGameView> with SingleTickerProviderStateMixin {
  final GlobalKey _gridKey = GlobalKey();
  late AnimationController _shakeController;
  int shakeCount = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void startShake(BuildContext context) {
    _shakeController.forward(from: 0).then((_) {
      if (shakeCount < 3) {
        shakeCount++;
        _shakeController.reverse().then((_) => startShake(context));
      } else {
        _shakeController.reset();
        shakeCount = 0;
        context.read<GameBloc>().add(StopShakingEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        centerTitle: true,
      ),
      backgroundColor: Colors.greenAccent,
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (!state.isCorrectWord && state.isShaking) {
            startShake(context);
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current Word: ${state.currentWord}',
                style: TextStyle(
                  fontSize: 24,
                  color: state.isCorrectWord ? Colors.purple : Colors.black,
                ),
              ),
              if (state.isCorrectWord)
                const Text(
                  youAreRight,
                  style: TextStyle(fontSize: 20),
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
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final offset = sin(_shakeController.value * pi) * 10;
                        return Transform.translate(
                          offset: Offset(!state.isCorrectWord ? offset : 0, 0),
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
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: widget.gridSize,
                                ),
                                itemCount: widget.gridSize * widget.gridSize,
                                itemBuilder: (context, index) {
                                  final row = index ~/ widget.gridSize;
                                  final col = index % widget.gridSize;
                                  final position = Position(row, col);
                                  final isSelected = state.selectedPositions.contains(position);
                                  return LetterCell(
                                    letter: state.letters[row][col],
                                    isSelected: isSelected,
                                    isCorrect: state.isCorrectWord,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _shakeController.reset();
                  shakeCount = 0;
                  context.read<GameBloc>().add(ResetGameEvent());
                },
                child: const Text(reset),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleDrag(BuildContext context, Offset globalPosition, DragEventCreator createEvent) {
    if (_gridKey.currentContext == null || _gridKey.currentContext?.mounted == false) {
      return;
    }
    final RenderBox box = _gridKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    final cellSize = boxSize / widget.gridSize;

    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();

    if (row >= 0 && row < widget.gridSize && col >= 0 && col < widget.gridSize) {
      context.read<GameBloc>().add(createEvent(
            row,
            col,
            (col * cellSize) + (cellSize / 2),
            (row * cellSize) + (cellSize / 2),
          ));
    }
  }

  void _handleDragStart(BuildContext context, DragStartDetails details) {
    _handleDrag(
      context,
      details.globalPosition,
      (row, col, dx, dy) => StartDragEvent(row, col, dx, dy),
    );
  }

  void _handleDragUpdate(BuildContext context, DragUpdateDetails details) {
    _handleDrag(
      context,
      details.globalPosition,
      (row, col, dx, dy) => UpdateDragEvent(row, col, dx, dy),
    );
  }
}
