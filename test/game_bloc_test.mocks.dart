// Mocks generated by Mockito 5.4.4 from annotations
// in word_game_bloc/test/game_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:math' as _i2;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i4;
import 'package:word_game_bloc/model/position.dart' as _i5;
import 'package:word_game_bloc/services/audio_service.dart' as _i6;
import 'package:word_game_bloc/services/word_placer.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeRandom_0 extends _i1.SmartFake implements _i2.Random {
  _FakeRandom_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [WordPlacer].
///
/// See the documentation for Mockito's code generation for more information.
class MockWordPlacer extends _i1.Mock implements _i3.WordPlacer {
  MockWordPlacer() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get targetWord => (super.noSuchMethod(
        Invocation.getter(#targetWord),
        returnValue: _i4.dummyValue<String>(
          this,
          Invocation.getter(#targetWord),
        ),
      ) as String);

  @override
  int get gridSize => (super.noSuchMethod(
        Invocation.getter(#gridSize),
        returnValue: 0,
      ) as int);

  @override
  List<List<String>> get grid => (super.noSuchMethod(
        Invocation.getter(#grid),
        returnValue: <List<String>>[],
      ) as List<List<String>>);

  @override
  set grid(List<List<String>>? _grid) => super.noSuchMethod(
        Invocation.setter(
          #grid,
          _grid,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.Random get random => (super.noSuchMethod(
        Invocation.getter(#random),
        returnValue: _FakeRandom_0(
          this,
          Invocation.getter(#random),
        ),
      ) as _i2.Random);

  @override
  List<List<String>> reset() => (super.noSuchMethod(
        Invocation.method(
          #reset,
          [],
        ),
        returnValue: <List<String>>[],
      ) as List<List<String>>);

  @override
  List<List<String>> getGrid() => (super.noSuchMethod(
        Invocation.method(
          #getGrid,
          [],
        ),
        returnValue: <List<String>>[],
      ) as List<List<String>>);

  @override
  bool isValidPlacement() => (super.noSuchMethod(
        Invocation.method(
          #isValidPlacement,
          [],
        ),
        returnValue: false,
      ) as bool);

  @override
  List<_i5.Position> buildValidPath() => (super.noSuchMethod(
        Invocation.method(
          #buildValidPath,
          [],
        ),
        returnValue: <_i5.Position>[],
      ) as List<_i5.Position>);

  @override
  bool arePositionsConnected(List<_i5.Position>? positions) =>
      (super.noSuchMethod(
        Invocation.method(
          #arePositionsConnected,
          [positions],
        ),
        returnValue: false,
      ) as bool);
}

/// A class which mocks [AudioService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAudioService extends _i1.Mock implements _i6.AudioService {
  MockAudioService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<void> playSuccessSound() => (super.noSuchMethod(
        Invocation.method(
          #playSuccessSound,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
}