import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../data/app_services.dart';

class PuzzleSetScreen extends StatelessWidget {
  const PuzzleSetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PUZZLE SETS',
                    style: TextStyle(
                      fontFamily: 'Archivo Narrow',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 2, color: AppColors.ink),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, (int, int)>>(
                future: _loadProgress(),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? {};
                  return _SetGrid(progressData: data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, (int, int)>> _loadProgress() async {
    const sets = ['beginner', 'intermediate', 'expert'];
    final result = <String, (int, int)>{};
    for (final setId in sets) {
      final puzzles = await AppServices.instance.puzzles.loadSet(setId);
      final completed = await AppServices.instance.progress.completedIds(setId);
      result[setId] = (completed.length, puzzles.length);
    }
    return result;
  }
}

class _AppBar extends StatelessWidget {
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
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: null,
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

class _SetGrid extends StatelessWidget {
  final Map<String, (int, int)> progressData;

  const _SetGrid({required this.progressData});

  static const _sets = [
    _SetConfig(
      id: 'beginner',
      label: 'BEGINNER',
      bgColor: AppColors.secondaryContainer,
      fgColor: AppColors.ink,
      icon: Icons.change_history,
    ),
    _SetConfig(
      id: 'intermediate',
      label: 'INTERMEDIATE',
      bgColor: AppColors.tertiaryContainer,
      fgColor: Colors.white,
      icon: Icons.square_outlined,
    ),
    _SetConfig(
      id: 'expert',
      label: 'EXPERT',
      bgColor: AppColors.primary,
      fgColor: Colors.white,
      icon: Icons.category_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: _sets.map((cfg) {
        final (completed, total) = progressData[cfg.id] ?? (0, 0);
        return _SetTile(
          config: cfg,
          completed: completed,
          total: total,
          onTap: () => context.go('/sets/${cfg.id}/levels'),
        );
      }).toList(),
    );
  }
}

class _SetConfig {
  final String id;
  final String label;
  final Color bgColor;
  final Color fgColor;
  final IconData icon;

  const _SetConfig({
    required this.id,
    required this.label,
    required this.bgColor,
    required this.fgColor,
    required this.icon,
  });
}

class _SetTile extends StatelessWidget {
  final _SetConfig config;
  final int completed;
  final int total;
  final VoidCallback onTap;

  const _SetTile({
    required this.config,
    required this.completed,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: config.bgColor,
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  config.label,
                  style: TextStyle(
                    fontFamily: 'Archivo Narrow',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: config.fgColor,
                  ),
                ),
                Icon(config.icon, color: config.fgColor, size: 32),
              ],
            ),
            const Spacer(),
            Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.ink, width: 2),
                color: AppColors.background,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$completed/$total SOLVED',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: config.fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
