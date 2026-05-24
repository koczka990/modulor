import 'package:go_router/go_router.dart';

import 'screens/welcome_screen.dart';
import 'screens/puzzle_set_screen.dart';
import 'screens/level_select_screen.dart';
import 'widgets/game_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/sets',
      builder: (context, state) => const PuzzleSetScreen(),
    ),
    GoRoute(
      path: '/sets/:setId/levels',
      builder: (context, state) => LevelSelectScreen(
        setId: state.pathParameters['setId']!,
      ),
    ),
    GoRoute(
      path: '/sets/:setId/levels/:levelIndex/play',
      builder: (context, state) => GameScreen(
        setId: state.pathParameters['setId']!,
        levelIndex: int.parse(state.pathParameters['levelIndex']!),
      ),
    ),
  ],
);
