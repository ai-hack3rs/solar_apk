// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:solar_calculator/providers/calculator_provider.dart';
import 'package:solar_calculator/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CalculatorProvider(),
        child: const SolarCalculatorApp(),
      ),
    );

    // Verify that the title is present or that the widget built successfully.
    // 'Solar Calculator' text might not be directly rendered as a Text widget 
    // depending on the AppBar configuration, but pumpWidget succeeding means no crash.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
