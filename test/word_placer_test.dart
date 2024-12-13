import 'package:flutter_test/flutter_test.dart';
import 'package:word_game_bloc/model/position.dart';
import 'package:word_game_bloc/services/word_placer.dart';

void main() {
  group('WordPlacer', () {
    late WordPlacer wordPlacer;
    const gridSize = 4;
    const tooLongWord = 'VERYLONGWORD!!!!!';
    const testWord = 'Test';

    setUp(() {
      wordPlacer = WordPlacer(testWord, gridSize);
    });

    test('initialization creates non-empty grid of correct size', () {
      final grid = wordPlacer.getGrid();
      expect(grid.length, gridSize);
      for (final row in grid) {
        expect(row.length, gridSize);
        for (final cell in row) {
          expect(cell.isNotEmpty, true);
          expect(cell.length, 1);
          expect(cell.contains(RegExp(r'[A-Z]')), true);
        }
      }
    });

    test('isValidPlacement returns true when word fits in grid', () {
      expect(wordPlacer.isValidPlacement(), true);
    });

    test('buildValidPath returns connected positions', () {
      final path = wordPlacer.buildValidPath();

      expect(path.length, testWord.length);
      expect(wordPlacer.arePositionsConnected(path), true);

      // Verify all positions are within grid bounds
      for (final pos in path) {
        expect(pos.row >= 0 && pos.row < gridSize, true);
        expect(pos.col >= 0 && pos.col < gridSize, true);
      }

      // Verify positions are actually connected (adjacent)
      for (int i = 1; i < path.length; i++) {
        final current = path[i];
        final previous = path[i - 1];
        final rowDiff = (current.row - previous.row).abs();
        final colDiff = (current.col - previous.col).abs();

        // Positions should be adjacent (not diagonal)
        expect(rowDiff + colDiff, 1);
      }
    });

    test('generateGrid places word correctly in grid', () {
      final upperWord = testWord.toUpperCase();
      final grid = wordPlacer.reset();

      // Find a connected sequence of the word letters
      List<Position>? wordPath;

      // Try each possible starting position and consider both forward and reverse word
      for (int i = 0; i < gridSize && wordPath == null; i++) {
        for (int j = 0; j < gridSize && wordPath == null; j++) {
          // Try forward word
          if (grid[i][j] == upperWord[0]) {
            wordPath = _findWordPath(grid, upperWord, Position(i, j));
          }
          // Try reverse word
          if (wordPath == null && grid[i][j] == upperWord[upperWord.length - 1]) {
            wordPath = _findWordPath(grid, String.fromCharCodes(upperWord.codeUnits.reversed), Position(i, j));
          }
        }
      }

      expect(wordPath, isNotNull, reason: 'Word $upperWord should be found in the grid');
      expect(wordPath!.length, upperWord.length);
      expect(wordPlacer.arePositionsConnected(wordPath), true);

      // Verify the letters along the path form our word (in either direction)
      final foundWord = wordPath.map((pos) => grid[pos.row][pos.col]).join();
      expect(foundWord == upperWord || foundWord == String.fromCharCodes(upperWord.codeUnits.reversed), true,
          reason: 'Found word $foundWord should match target word $upperWord in either direction');
    });

    test('reset generates new valid grid', () {
      final firstGrid = wordPlacer.getGrid();
      final secondGrid = wordPlacer.reset();

      // Verify grid dimensions
      expect(secondGrid.length, gridSize);
      for (final row in secondGrid) {
        expect(row.length, gridSize);
      }

      // Verify all cells contain valid letters
      for (final row in secondGrid) {
        for (final cell in row) {
          expect(cell.length, 1);
          expect(cell.contains(RegExp(r'[A-Z]')), true);
        }
      }

      // Check that grids are different
      bool areGridsDifferent = false;
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (firstGrid[i][j] != secondGrid[i][j]) {
            areGridsDifferent = true;
            break;
          }
        }
        if (areGridsDifferent) break;
      }
      expect(areGridsDifferent, true, reason: 'Reset should generate a different grid');
    });

    test('adjacent letters are different', () {
      final grid = wordPlacer.reset();

      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          final currentLetter = grid[i][j];
          final adjacentLetters = _getAdjacentLetters(grid, i, j, gridSize);

          for (final adjLetter in adjacentLetters) {
            expect(adjLetter != currentLetter, true,
                reason: 'Adjacent letters should be different at position ($i,$j)');
          }
        }
      }
    });

    test('arePositionsConnected returns true for valid path', () {
      final positions = [
        Position(0, 0),
        Position(0, 1),
        Position(1, 1),
      ];
      expect(wordPlacer.arePositionsConnected(positions), true);
    });

    test('arePositionsConnected returns false for disconnected path', () {
      final positions = [
        Position(0, 0),
        Position(2, 2), // Disconnected
        Position(0, 2),
      ];
      expect(wordPlacer.arePositionsConnected(positions), false);
    });

    test('arePositionsConnected returns false for diagonal path', () {
      final positions = [
        Position(0, 0),
        Position(1, 1), // Diagonal
        Position(2, 2),
      ];
      expect(wordPlacer.arePositionsConnected(positions), false);
    });

    test('generateGrid throws exception when word is too long', () {
      expect(() => WordPlacer(tooLongWord, gridSize), throwsException);
    });

    test('generates different grids on multiple resets', () {
      final grids = List.generate(5, (_) => wordPlacer.reset());

      // Compare each grid with others to ensure they're not all identical
      bool foundDifference = false;
      final firstGrid = grids[0];
      for (final grid in grids.skip(1)) {
        bool identical = true;
        for (int i = 0; i < gridSize; i++) {
          for (int j = 0; j < gridSize; j++) {
            if (grid[i][j] != firstGrid[i][j]) {
              identical = false;
              foundDifference = true;
              break;
            }
          }
          if (!identical) break;
        }
      }
      expect(foundDifference, true, reason: 'At least some generated grids should be different');
    });
  });
}

List<Position>? _findWordPath(List<List<String>> grid, String word, Position start) {
  if (grid[start.row][start.col] != word[0]) return null;

  final List<Position> path = [start];
  final Set<Position> visited = {start};

  if (_extendPath(grid, word, path, visited, 1)) {
    return path;
  }
  return null;
}

bool _extendPath(List<List<String>> grid, String word, List<Position> path, Set<Position> visited, int wordIndex) {
  if (wordIndex >= word.length) return true;

  final directions = [
    Position(-1, 0), // up
    Position(1, 0), // down
    Position(0, -1), // left
    Position(0, 1), // right
  ];

  final current = path.last;
  for (final dir in directions) {
    final newPos = Position(
      current.row + dir.row,
      current.col + dir.col,
    );

    if (_isValidPosition(grid, newPos) &&
        !visited.contains(newPos) &&
        grid[newPos.row][newPos.col] == word[wordIndex]) {
      path.add(newPos);
      visited.add(newPos);

      if (_extendPath(grid, word, path, visited, wordIndex + 1)) {
        return true;
      }

      path.removeLast();
      visited.remove(newPos);
    }
  }

  return false;
}

bool _isValidPosition(List<List<String>> grid, Position pos) {
  return pos.row >= 0 && pos.row < grid.length && pos.col >= 0 && pos.col < grid[0].length;
}

List<String> _getAdjacentLetters(List<List<String>> grid, int row, int col, int gridSize) {
  final List<String> adjacent = [];
  final directions = [
    [-1, 0], // up
    [1, 0], // down
    [0, -1], // left
    [0, 1], // right
  ];

  for (final dir in directions) {
    final newRow = row + dir[0];
    final newCol = col + dir[1];

    if (newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize) {
      adjacent.add(grid[newRow][newCol]);
    }
  }

  return adjacent;
}
