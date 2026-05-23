import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.archivoNarrowTextTheme(),
        useMaterial3: true,
      ),
      home: const GameScreen(puzzle: kHardcodedPuzzle),
    );
  }
}
