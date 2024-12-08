import 'package:flutter/material.dart';

class LetterCell extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isCorrect;

  const LetterCell({
    super.key,
    required this.letter,
    required this.isSelected,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purpleAccent : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (isSelected && !isCorrect) ? Colors.red : Colors.purple, width: isSelected ? 3 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
