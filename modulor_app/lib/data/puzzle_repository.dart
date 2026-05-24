import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/puzzle.dart';

class PuzzleRepository {
  final Map<String, List<Puzzle>> _cache = {};

  Future<List<Puzzle>> loadSet(String setId) async {
    if (_cache.containsKey(setId)) return _cache[setId]!;

    final jsonStr = await rootBundle.loadString('assets/puzzles/$setId.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final puzzles = (data['puzzles'] as List)
        .map((p) => Puzzle.fromJson(p as Map<String, dynamic>))
        .toList();
    _cache[setId] = puzzles;
    return puzzles;
  }
}
