import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_switch/liquid_glass_switch.dart';

void main() {
  Widget buildHarness({
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LiquidGlassSwitch(
            value: value,
            onChanged: onChanged,
            enabled: enabled,
          ),
        ),
      ),
    );
  }

  testWidgets('renders with default faces', (tester) async {
    await tester.pumpWidget(buildHarness(value: false, onChanged: (_) {}));

    expect(find.byType(LiquidGlassSwitch), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('tap toggles once and calls onChanged once', (tester) async {
    bool value = false;
    int callbackCount = 0;
    bool? callbackValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: LiquidGlassSwitch(
                  value: value,
                  onChanged: (next) {
                    callbackCount++;
                    callbackValue = next;
                    setState(() {
                      value = next;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LiquidGlassSwitch));
    await tester.pumpAndSettle();

    expect(callbackCount, 1);
    expect(callbackValue, isTrue);
    expect(find.text('Sleep'), findsOneWidget);
  });

  testWidgets('drag right commits to true and calls onChanged once', (
    tester,
  ) async {
    bool value = false;
    int callbackCount = 0;
    bool? callbackValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: LiquidGlassSwitch(
                  value: value,
                  onChanged: (next) {
                    callbackCount++;
                    callbackValue = next;
                    setState(() {
                      value = next;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.drag(find.byType(LiquidGlassSwitch), const Offset(140, 0));
    await tester.pumpAndSettle();

    expect(callbackCount, 1);
    expect(callbackValue, isTrue);
    expect(find.text('Sleep'), findsOneWidget);
  });

  testWidgets('disabled switch does not react to tap or drag', (tester) async {
    int callbackCount = 0;

    await tester.pumpWidget(
      buildHarness(
        value: false,
        enabled: false,
        onChanged: (_) {
          callbackCount++;
        },
      ),
    );

    await tester.tap(find.byType(LiquidGlassSwitch));
    await tester.drag(find.byType(LiquidGlassSwitch), const Offset(140, 0));
    await tester.pumpAndSettle();

    expect(callbackCount, 0);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('external value update animates to new state', (tester) async {
    bool value = false;

    await tester.pumpWidget(buildHarness(value: value, onChanged: (_) {}));

    expect(find.text('Work'), findsOneWidget);

    value = true;
    await tester.pumpWidget(buildHarness(value: value, onChanged: (_) {}));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Sleep'), findsOneWidget);
  });
}
