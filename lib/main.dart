import 'package:flutter/material.dart';
import 'package:word_game_bloc/constants.dart';
import 'package:word_game_bloc/ui/screens/word_game_screen.dart';

void main() {
  runApp(const WordGameApp());
}

class WordGameApp extends StatelessWidget {
  const WordGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WordGameScreen(
        word: 'VuElTo',
        gridSize: 4,
      ),
    );
  }
}