import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../data/app_services.dart';
import '../models/puzzle.dart';

enum _LevelState { completed, current, locked }

class LevelSelectScreen extends StatelessWidget {
  final String setId;

  const LevelSelectScreen({super.key, required this.setId});

  String get _setLabel => switch (setId) {
        'beginner'     => 'BEGINNER',
        'intermediate' => 'INTERMEDIATE',
        'expert'       => 'EXPERT',
        _              => setId.toUpperCase(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LevelAppBar(setId: setId),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'LEVELS',
                        style: TextStyle(
                          fontFamily: 'Archivo Narrow',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        _setLabel,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(height: 2, color: AppColors.ink),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<(List<Puzzle>, Set<String>)>(
                future: _loadData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final (puzzles, completed) = snapshot.data!;
                  return _LevelGrid(
                    puzzles: puzzles,
                    completed: completed,
                    setId: setId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<(List<Puzzle>, Set<String>)> _loadData() async {
    final puzzles = await AppServices.instance.puzzles.loadSet(setId);
    final completed = await AppServices.instance.progress.completedIds(setId);
    return (puzzles, completed);
  }
}

class _LevelAppBar extends StatelessWidget {
  final String setId;
  const _LevelAppBar({required this.setId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.ink, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => context.go('/sets'),
          ),
          const Text(
            'MODULOR',
            style: TextStyle(
              fontFamily: 'Archivo Narrow',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final List<Puzzle> puzzles;
  final Set<String> completed;
  final String setId;

  static const _completedColors = [
    AppColors.primary,
    AppColors.secondaryContainer,
    AppColors.tertiaryContainer,
  ];

  const _LevelGrid({
    required this.puzzles,
    required this.completed,
    required this.setId,
  });

  _LevelState _stateFor(int index) {
    final isCompleted = completed.contains(puzzles[index].id);
    if (isCompleted) return _LevelState.completed;
    final isUnlocked = index == 0 || completed.contains(puzzles[index - 1].id);
    if (!isUnlocked) return _LevelState.locked;
    return _LevelState.current;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: puzzles.length,
      itemBuilder: (context, index) {
        final state = _stateFor(index);
        return _LevelCell(
          index: index,
          state: state,
          completedColor: _completedColors[index % 3],
          onTap: state != _LevelState.locked
              ? () => context.go('/sets/$setId/levels/$index/play')
              : null,
        );
      },
    );
  }
}

class _LevelCell extends StatelessWidget {
  final int index;
  final _LevelState state;
  final Color completedColor;
  final VoidCallback? onTap;

  const _LevelCell({
    required this.index,
    required this.state,
    required this.completedColor,
    required this.onTap,
  });

  Color get _bgColor => switch (state) {
        _LevelState.completed => completedColor,
        _LevelState.current   => AppColors.background,
        _LevelState.locked    => const Color(0xFFE1E3E4),
      };

  Widget? get _centerIcon => switch (state) {
        _LevelState.current => const Icon(
            Icons.play_arrow,
            color: AppColors.ink,
            size: 40,
          ),
        _LevelState.locked => const Icon(
            Icons.lock_outline,
            color: AppColors.ink,
            size: 28,
          ),
        _LevelState.completed => null,
      };

  @override
  Widget build(BuildContext context) {
    final label = (index + 1).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: state == _LevelState.locked ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor,
            border: Border.all(
              color: state == _LevelState.current
                  ? AppColors.primary
                  : AppColors.ink,
              width: state == _LevelState.current ? 3 : 2,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 8,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Archivo Narrow',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (_centerIcon != null) Center(child: _centerIcon),
              Positioned(
                bottom: 8,
                right: 8,
                child: _Dots(filled: state == _LevelState.completed ? 3 : 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int filled;

  const _Dots({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: i < filled ? AppColors.ink : Colors.transparent,
            border: Border.all(color: AppColors.ink, width: 1),
          ),
        );
      }),
    );
  }
}
