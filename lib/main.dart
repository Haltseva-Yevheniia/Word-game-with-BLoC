// lib/blocs/game_bloc.dart
import 'package:flutter/material.dart';
import 'package:word_game_bloc/screens/word_game_screen.dart';
//import 'package:word_game_bloc/screens/game_screen.dart';
//import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const WordGameApp());
}

class WordGameApp extends StatelessWidget {
  const WordGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WordGameScreen(),
    );
  }
}
