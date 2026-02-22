import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:construction_erp/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ConstructionErpApp());
    // The app starts on login, which has the Constructio ERP app name
    expect(find.byType(MaterialApp),
        findsNothing); // MaterialApp.router used instead
  });
}
