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
  const WordGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(InitializeGameEvent()),
      child: const _WordGameView(),
    );
  }
}

class _WordGameView extends StatefulWidget {
  const _WordGameView();

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
                  color: state.isCorrectWord ? Colors.green : Colors.black,
                ),
              ),
              if (state.isCorrectWord)
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    youAreRight,
                    style: TextStyle(fontSize: 20),
                  ),
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
                        AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            final offset = sin(_shakeController.value * pi) * 10;
                            return Transform.translate(
                              offset: Offset(!state.isCorrectWord ? offset : 0, 0),
                              child: GridView.builder(
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
                                    isCorrect: state.isCorrectWord,
                                  );
                                },
                              ),
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
                onPressed: () {
                  _shakeController.reset();
                  shakeCount = 0;
                  context.read<GameBloc>().add(ResetGameEvent());
                },
                child: const Text('Reset'),
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
    const cellSize = boxSize / GameBloc.gridSize;
    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();

    if (row >= 0 && row < GameBloc.gridSize && col >= 0 && col < GameBloc.gridSize) {
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
