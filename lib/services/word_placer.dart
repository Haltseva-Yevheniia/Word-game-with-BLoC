import 'dart:math';

import 'package:word_game_bloc/model/position.dart';

class WordPlacer {
  final String targetWord;
  final int gridSize;
  List<List<String>> grid;
  final random = Random();

  WordPlacer(String word, this.gridSize)
      : targetWord = word.toUpperCase(),
        grid = [] {
    reset();
  }

  List<List<String>> reset() {
    grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    return _generateGrid();
  }

  List<List<String>> getGrid() {
    return grid;
  }

  bool isValidPlacement() {
    return targetWord.length <= gridSize * gridSize;
  }

  ///Place target word in a grid randomly but in a way it can be selected by user swipe
  List<Position> buildValidPath() {
    // Make a list of all possible starting positions
    List<Position> allStartPositions = [];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        allStartPositions.add(Position(row, col));
      }
    }

    allStartPositions.shuffle(random);

    for (Position startPos in allStartPositions) {
      List<Position> path = [];
      Set<Position> visitedPositions = {};

      path.add(startPos);
      visitedPositions.add(startPos);

      if (_buildPathFromPosition(path, visitedPositions, 1)) {
        return path;
      }
    }

    throw Exception('Could not find valid path for word placement');
  }

  bool _buildPathFromPosition(List<Position> path, Set<Position> visitedPositions, int currentIndex) {
    if (currentIndex >= targetWord.length) {
      return true;
    }

    final List<Position> directions = [
      Position(-1, 0), // up
      Position(1, 0), // down
      Position(0, -1), // left
      Position(0, 1), // right
    ];

    directions.shuffle(random);

    Position current = path.last;
    final Set<Position> triedPositions = {};

    for (Position direction in directions) {
      Position newPos = Position(
        current.row + direction.row,
        current.col + direction.col,
      );

      if (_isValidPosition(newPos) && !visitedPositions.contains(newPos) && !triedPositions.contains(newPos)) {
        triedPositions.add(newPos);
        path.add(newPos);
        visitedPositions.add(newPos);

        if (_buildPathFromPosition(path, visitedPositions, currentIndex + 1)) {
          return true;
        }

        path.removeLast();
        visitedPositions.remove(newPos);
      }
    }

    return false;
  }

  bool _isValidPosition(Position pos) {
    return pos.row >= 0 && pos.row < gridSize && pos.col >= 0 && pos.col < gridSize;
  }

  List<List<String>> _generateGrid() {
    if (!isValidPlacement()) {
      throw Exception('Word is too long for the given grid size');
    }

    List<Position> path = buildValidPath();

    for (int i = 0; i < targetWord.length; i++) {
      Position pos = path[i];
      grid[pos.row][pos.col] = targetWord[i];
    }

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        Position currentPos = Position(i, j);
        if (grid[i][j].isEmpty) {
          grid[i][j] = _getRandomLetter(currentPos);
        }
      }
    }

    return grid;
  }

  String _getRandomLetter(Position pos) {
    const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    List<String> adjacentLetters = _getAdjacentLetters(pos);

    String randomLetter;
    do {
      randomLetter = alphabet[random.nextInt(alphabet.length)];
    } while (adjacentLetters.contains(randomLetter));

    return randomLetter;
  }

  List<String> _getAdjacentLetters(Position pos) {
    List<String> adjacent = [];
    final List<Position> directions = [
      Position(-1, 0), // up
      Position(1, 0), // down
      Position(0, -1), // left
      Position(0, 1), // right
    ];

    for (Position direction in directions) {
      Position newPos = Position(
        pos.row + direction.row,
        pos.col + direction.col,
      );

      if (_isValidPosition(newPos) && grid[newPos.row][newPos.col].isNotEmpty) {
        adjacent.add(grid[newPos.row][newPos.col]);
      }
    }

    return adjacent;
  }

  bool arePositionsConnected(List<Position> positions) {
    if (positions.length < 2) return true;

    for (int i = 1; i < positions.length; i++) {
      Position current = positions[i];
      Position previous = positions[i - 1];

      int rowDiff = (current.row - previous.row).abs();
      int colDiff = (current.col - previous.col).abs();

      if ((rowDiff > 0 && colDiff > 0) || rowDiff > 1 || colDiff > 1) {
        return false;
      }
    }

    return true;
  }
}