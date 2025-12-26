// Basic widget test for Orin app

import 'package:flutter_test/flutter_test.dart';
import 'package:orin/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OrinApp());

    // Verify that splash screen shows
    expect(find.text('ORIN'), findsOneWidget);
  });
}
