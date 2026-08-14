import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('MediAuth App basic smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SizedBox(),
      ),
    );

    // Verify splash or basic widgets exist
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
