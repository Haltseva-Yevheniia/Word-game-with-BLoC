
import 'dart:math';

import 'package:word_game_bloc/model/position.dart';

class WordPlacement {
  final String word;
  final int gridSize;
  late List<List<String>> grid;
  final random = Random();

  WordPlacement(this.word, this.gridSize) {
    grid = List.generate(
      gridSize,
          (_) => List.generate(gridSize, (_) => ''),
    );
  }

  bool isValidPlacement() {
    return word.length <= gridSize * gridSize && word.length <= gridSize * 2 - 1;
  }

  List<Position> findValidPath() {
    for (int attempt = 0; attempt < 100; attempt++) {

      int startRow = random.nextInt(gridSize);
      int startCol = random.nextInt(gridSize);

      List<Position> path = [];
      Set<Position> visitedPositions = {};

      Position startPos = Position(startRow, startCol);
      path.add(startPos);
      visitedPositions.add(startPos);

      bool success = _buildPath(path, visitedPositions, 1);
      if (success) {
        return path;
      }
    }

    throw Exception('Could not find valid path for word placement');
  }

  bool _buildPath(List<Position> path, Set<Position> visitedPositions, int currentIndex) {
    if (currentIndex >= word.length) {
      return true;
    }

    final List<Position> directions = [
      Position(-1, 0),  // up
      Position(1, 0),   // down
      Position(0, -1),  // left
      Position(0, 1),   // right
    ];

    directions.shuffle(random);

    Position current = path.last;

    for (Position direction in directions) {
      Position newPos = Position(
        current.row + direction.row,
        current.col + direction.col,
      );

      if (_isValidPosition(newPos) && !visitedPositions.contains(newPos)) {
        path.add(newPos);
        visitedPositions.add(newPos);

        if (_buildPath(path, visitedPositions, currentIndex + 1)) {
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

  List<List<String>> generateGrid() {
    if (!isValidPlacement()) {
      throw Exception('Word is too long for the given grid size');
    }

    List<Position> path = findValidPath();

    for (int i = 0; i < word.length; i++) {
      Position pos = path[i];
      grid[pos.row][pos.col] = word[i];
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
      Position(-1, 0),  // up
      Position(1, 0),   // down
      Position(0, -1),  // left
      Position(0, 1),   // right
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