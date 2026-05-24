import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/data/app_services.dart';
import 'package:modulor_app/widgets/game_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppServices.instance.initForTesting();
  });

  Widget buildGame() {
    return const MaterialApp(
      home: GameScreen(setId: 'beginner', levelIndex: 0),
    );
  }

  testWidgets('MODULOR title is visible after puzzle loads', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.pumpAndSettle();
    expect(find.text('MODULOR'), findsOneWidget);
  });

  testWidgets('hint button is visible after puzzle loads', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
  });

  testWidgets('settings menu button is visible after puzzle loads', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('settings menu contains Restart option', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('tapping Restart does not crash', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();
    expect(find.text('MODULOR'), findsOneWidget);
  });

  testWidgets('check button is not visible when board is empty', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.pumpAndSettle();
    expect(find.text('CHECK'), findsNothing);
  });

  testWidgets('clue strip is visible after puzzle loads', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
