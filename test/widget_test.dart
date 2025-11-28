import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kundali_app/main.dart';

void main() {
  testWidgets('App starts test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KundaliApp());

    // Verify that app starts
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
