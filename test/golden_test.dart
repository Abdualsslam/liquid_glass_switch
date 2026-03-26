import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_switch/liquid_glass_switch.dart';

void main() {
  Future<void> pumpGolden(
    WidgetTester tester,
    LiquidGlassSwitchValue value, {
    LiquidGlassSwitchValue? animateTo,
    Duration animationStep = Duration.zero,
  }) async {
    await tester.binding.setSurfaceSize(const Size(680, 460));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Widget buildGoldenRoot(LiquidGlassSwitchValue currentValue) {
      return MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: const ValueKey('golden-root'),
            child: Container(
              width: 680,
              height: 460,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3A3F48),
                    Color(0xFF343941),
                    Color(0xFF2B3038),
                  ],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.62),
                          radius: 1.0,
                          colors: [
                            Colors.white.withValues(alpha: 0.09),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: LiquidGlassSwitch(
                      value: currentValue,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildGoldenRoot(value));

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    if (animateTo != null) {
      await tester.pumpWidget(buildGoldenRoot(animateTo));
      await tester.pump(animationStep);
    }
  }

  testWidgets('golden dark state', (tester) async {
    await pumpGolden(tester, LiquidGlassSwitchValue.dark);
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('goldens/liquid_glass_switch_dark.png'),
    );
  });

  testWidgets('golden light state', (tester) async {
    await pumpGolden(tester, LiquidGlassSwitchValue.light);
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('goldens/liquid_glass_switch_light.png'),
    );
  });

  testWidgets('golden mid transition state', (tester) async {
    await pumpGolden(
      tester,
      LiquidGlassSwitchValue.dark,
      animateTo: LiquidGlassSwitchValue.light,
      animationStep: const Duration(milliseconds: 70),
    );
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('goldens/liquid_glass_switch_mid.png'),
    );
  });
}
