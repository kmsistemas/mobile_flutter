import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:kmindustrial/main.dart";
import "package:kmindustrial/screens/login_screen.dart";

void main() {
  testWidgets('App renders login screen', (tester) async {
    await tester.pumpWidget(const KmIndustrialApp());

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
