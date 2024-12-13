import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_game_bloc/ui/components/line_painter.dart';


void main() {
  group('LinePainter', () {
    test('shouldRepaint returns true when points are different', () {
      final oldPainter = LinePainter(
        points: [const Offset(0, 0), const Offset(1, 1)],
      );

      final newPainter = LinePainter(
        points: [const Offset(0, 0), const Offset(2, 2)],
      );

      expect(newPainter.shouldRepaint(oldPainter), true);
    });

    test('shouldRepaint returns true when currentDragPosition is different', () {
      final oldPainter = LinePainter(
        points: [const Offset(0, 0)],
        currentDragPosition: const Offset(1, 1),
      );

      final newPainter = LinePainter(
        points: [const Offset(0, 0)],
        currentDragPosition: const Offset(2, 2),
      );

      expect(newPainter.shouldRepaint(oldPainter), true);
    });

    test('shouldRepaint returns false when points and currentDragPosition are the same', () {
      final points = [const Offset(0, 0), const Offset(1, 1)];
      const dragPosition = Offset(2, 2);

      final oldPainter = LinePainter(
        points: points,
        currentDragPosition: dragPosition,
      );

      final newPainter = LinePainter(
        points: points,
        currentDragPosition: dragPosition,
      );

      expect(newPainter.shouldRepaint(oldPainter), false);
    });

    test('paint method handles empty points list', () {
      final painter = LinePainter(points: []);

      // Create a mock canvas and size
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(100, 100);

      // This should not throw an error
      painter.paint(canvas, size);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });
}