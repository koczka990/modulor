import 'package:flutter/material.dart';

class LevelSelectScreen extends StatelessWidget {
  final String setId;
  const LevelSelectScreen({super.key, required this.setId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Levels: $setId')));
  }
}
