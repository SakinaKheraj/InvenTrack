// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iventrack/providers/grocery_provider.dart';
import 'package:iventrack/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('navigate to recipe suggestions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GroceryProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // allow frame
    await tester.pumpAndSettle();

    // Tap recipe button
    final recipeButton = find.byIcon(Icons.local_dining);
    expect(recipeButton, findsOneWidget);
    await tester.tap(recipeButton);
    await tester.pumpAndSettle();

    expect(find.text('Recipe Suggestions'), findsOneWidget);
  });
}
