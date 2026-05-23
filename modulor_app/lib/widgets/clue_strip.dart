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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: clues.indexed
            .map((e) => ClueCard(clue: e.$2, index: e.$1))
            .toList(),
      ),
    );
  }
}
