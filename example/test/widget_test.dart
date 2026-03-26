import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app renders liquid glass switch', (tester) async {
    await tester.pumpWidget(const LiquidGlassSwitchExampleApp());

    expect(find.text('Sleep'), findsOneWidget);
  });
}
