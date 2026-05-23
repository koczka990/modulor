import 'package:flutter/material.dart';
import '../models/clue.dart';
import 'clue_card.dart';

class ClueStrip extends StatelessWidget {
  final List<Clue> clues;

  const ClueStrip({super.key, required this.clues});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: clues.map((c) => ClueCard(clue: c)).toList(),
      ),
    );
  }
}
