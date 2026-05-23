import 'package:flutter/material.dart';
import 'models/puzzle.dart';
import 'widgets/game_screen.dart';

void main() {
  runApp(const ModulorApp());
}

class ModulorApp extends StatelessWidget {
  const ModulorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modulor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const GameScreen(puzzle: kHardcodedPuzzle),
    );
  }
}
