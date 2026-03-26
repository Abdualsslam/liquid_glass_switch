import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_switch/liquid_glass_switch.dart';

void main() {
  const trackBaseKey = ValueKey<String>('liquid_glass_switch_track_base');
  const labelSlotKey = ValueKey<String>('liquid_glass_switch_label_slot');
  const leftLabelSlotKey = ValueKey<String>(
    'liquid_glass_switch_left_label_slot',
  );
  const rightLabelSlotKey = ValueKey<String>(
    'liquid_glass_switch_right_label_slot',
  );
  const leftLabelOpacityKey = ValueKey<String>(
    'liquid_glass_switch_left_label_opacity',
  );
  const rightLabelOpacityKey = ValueKey<String>(
    'liquid_glass_switch_right_label_opacity',
  );
  const orbSlotKey = ValueKey<String>('liquid_glass_switch_orb_slot');

  Widget buildHarness({
    required LiquidGlassSwitchValue value,
    required ValueChanged<LiquidGlassSwitchValue> onChanged,
    bool enabled = true,
    ValueChanged<double>? onPositionChanged,
    LiquidGlassSwitchContent content =
        const LiquidGlassSwitchContent.darkLight(),
    LiquidGlassSwitchStyle style = const LiquidGlassSwitchStyle(),
    LiquidGlassSwitchMotion motion = const LiquidGlassSwitchMotion(),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LiquidGlassSwitch(
            value: value,
            onChanged: onChanged,
            content: content,
            style: style,
            motion: motion,
            enabled: enabled,
            onPositionChanged: onPositionChanged,
          ),
        ),
      ),
    );
  }

  Color trackBaseColor(WidgetTester tester) {
    return tester.widget<ColoredBox>(find.byKey(trackBaseKey)).color;
  }

  double labelOpacity(WidgetTester tester, ValueKey<String> key) {
    return tester.widget<Opacity>(find.byKey(key)).opacity;
  }

  Matcher roughlyVisible() => closeTo(1.0, 0.001);
  Matcher roughlyHidden() => closeTo(0.0, 0.001);

  testWidgets('renders with dark default state', (tester) async {
    await tester.pumpWidget(
      buildHarness(value: LiquidGlassSwitchValue.dark, onChanged: (_) {}),
    );

    expect(find.byType(LiquidGlassSwitch), findsOneWidget);
    expect(labelOpacity(tester, leftLabelOpacityKey), roughlyVisible());
    expect(labelOpacity(tester, rightLabelOpacityKey), roughlyHidden());
  });

  testWidgets('tap toggles once and calls onChanged once', (tester) async {
    var value = LiquidGlassSwitchValue.dark;
    var callbackCount = 0;
    LiquidGlassSwitchValue? callbackValue;

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
    expect(callbackValue, LiquidGlassSwitchValue.light);
    expect(labelOpacity(tester, leftLabelOpacityKey), roughlyHidden());
    expect(labelOpacity(tester, rightLabelOpacityKey), roughlyVisible());
  });

  testWidgets('drag right commits to dark and calls onChanged once', (
    tester,
  ) async {
    var value = LiquidGlassSwitchValue.light;
    var callbackCount = 0;
    LiquidGlassSwitchValue? callbackValue;

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

    await tester.drag(find.byType(LiquidGlassSwitch), const Offset(180, 0));
    await tester.pumpAndSettle();

    expect(callbackCount, 1);
    expect(callbackValue, LiquidGlassSwitchValue.dark);
    expect(labelOpacity(tester, leftLabelOpacityKey), roughlyVisible());
    expect(labelOpacity(tester, rightLabelOpacityKey), roughlyHidden());
  });

  testWidgets('disabled switch does not react to tap or drag', (tester) async {
    var callbackCount = 0;

    await tester.pumpWidget(
      buildHarness(
        value: LiquidGlassSwitchValue.light,
        enabled: false,
        onChanged: (_) {
          callbackCount++;
        },
      ),
    );

    await tester.tap(find.byType(LiquidGlassSwitch));
    await tester.drag(find.byType(LiquidGlassSwitch), const Offset(180, 0));
    await tester.pumpAndSettle();

    expect(callbackCount, 0);
    expect(labelOpacity(tester, leftLabelOpacityKey), roughlyHidden());
    expect(labelOpacity(tester, rightLabelOpacityKey), roughlyVisible());
  });

  testWidgets('external value update animates to new state', (tester) async {
    var value = LiquidGlassSwitchValue.light;

    await tester.pumpWidget(buildHarness(value: value, onChanged: (_) {}));

    expect(find.text('Light'), findsOneWidget);

    value = LiquidGlassSwitchValue.dark;
    await tester.pumpWidget(buildHarness(value: value, onChanged: (_) {}));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(labelOpacity(tester, leftLabelOpacityKey), roughlyVisible());
    expect(labelOpacity(tester, rightLabelOpacityKey), roughlyHidden());
  });

  testWidgets('custom styles control track, indicator, icon, and labels', (
    tester,
  ) async {
    const customContent = LiquidGlassSwitchContent(
      left: LiquidGlassStateContent(
        label: 'Day',
        icon: Icons.wb_sunny_rounded,
        tint: Color(0xFFFFFFFF),
        iconColor: Color(0xFFF6C445),
        iconSize: 34.0,
        labelStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6E5431),
        ),
      ),
      right: LiquidGlassStateContent(
        label: 'Night',
        icon: Icons.dark_mode_rounded,
        tint: Color(0xFFFFFFFF),
        iconColor: Color(0xFFB8C7FF),
        iconSize: 32.0,
        labelStyle: TextStyle(fontSize: 24, color: Color(0xFF8FA3D9)),
      ),
    );
    const customStyle = LiquidGlassSwitchStyle(
      geometry: LiquidGlassGeometryStyle(
        trackWidth: 310,
        trackHeight: 104,
        orbSize: 132,
        indicatorWidth: 88,
        indicatorHeight: 148,
        orbOverflow: 16,
        labelPadding: EdgeInsets.symmetric(horizontal: 24),
        labelSafeZone: 112,
      ),
      orb: LiquidGlassOrbStyle(iconColor: Color(0xFF123456), iconSize: 44),
      typography: LiquidGlassTypographyStyle(
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Color(0xFF444444),
        ),
      ),
    );

    await tester.pumpWidget(
      buildHarness(
        value: LiquidGlassSwitchValue.light,
        onChanged: (_) {},
        content: customContent,
        style: customStyle,
      ),
    );

    final trackSize = tester.getSize(find.byKey(trackBaseKey));
    final orbRect = tester.getRect(find.byKey(orbSlotKey));
    final rightLabelSlot = tester.getSize(find.byKey(rightLabelSlotKey));
    final dayIcon = tester.widget<Icon>(find.byIcon(Icons.wb_sunny_rounded));
    final dayText = tester.widget<Text>(find.text('Day'));
    final nightText = tester.widget<Text>(find.text('Night'));

    expect(trackSize.width, 310);
    expect(trackSize.height, 104);
    expect(orbRect.width, 88);
    expect(orbRect.height, 148);
    expect(rightLabelSlot.width, closeTo(138.0, 0.001));
    expect(dayIcon.size, 34);
    expect(dayIcon.color?.toARGB32(), const Color(0xFFF6C445).toARGB32());
    expect(dayText.style?.fontSize, 26);
    expect(
      dayText.style?.color?.toARGB32(),
      const Color(0xFF6E5431).toARGB32(),
    );
    expect(nightText.style?.fontSize, 24);
    expect(
      nightText.style?.color?.toARGB32(),
      const Color(0xFF8FA3D9).toARGB32(),
    );
  });

  testWidgets('labelSafeZone is applied exactly without hidden orb minimums', (
    tester,
  ) async {
    const style = LiquidGlassSwitchStyle(
      geometry: LiquidGlassGeometryStyle(
        trackWidth: 200,
        trackHeight: 80,
        orbSize: 100,
        indicatorWidth: 100,
        indicatorHeight: 116,
        orbOverflow: 12,
        labelPadding: EdgeInsets.symmetric(horizontal: 20),
        labelSafeZone: 20,
        enforceOrbLabelClearance: false,
      ),
    );

    await tester.pumpWidget(
      buildHarness(
        value: LiquidGlassSwitchValue.light,
        onChanged: (_) {},
        style: style,
      ),
    );

    final rightLabelSlot = tester.getSize(find.byKey(rightLabelSlotKey));

    expect(rightLabelSlot.width, closeTo(128.0, 0.001));
  });

  testWidgets('label fit can stay fixed for direct typography control', (
    tester,
  ) async {
    const content = LiquidGlassSwitchContent(
      left: LiquidGlassStateContent(
        label: 'نهار',
        icon: Icons.wb_sunny_rounded,
        tint: Colors.white,
        labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        labelFit: LiquidGlassLabelFit.fixed,
        labelTextDirection: TextDirection.rtl,
      ),
      right: LiquidGlassStateContent(
        label: 'ليل',
        icon: Icons.dark_mode_rounded,
        tint: Colors.white,
        labelStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        labelFit: LiquidGlassLabelFit.fixed,
        labelTextDirection: TextDirection.rtl,
      ),
    );
    const style = LiquidGlassSwitchStyle(
      geometry: LiquidGlassGeometryStyle(
        trackWidth: 280,
        trackHeight: 92,
        orbSize: 104,
        indicatorWidth: 92,
        indicatorHeight: 128,
        orbOverflow: 14,
        labelPadding: EdgeInsets.symmetric(horizontal: 20),
        labelSafeZone: 48,
      ),
    );

    await tester.pumpWidget(
      buildHarness(
        value: LiquidGlassSwitchValue.light,
        onChanged: (_) {},
        content: content,
        style: style,
      ),
    );

    final dayText = tester.widget<Text>(find.text('نهار'));
    final nightText = tester.widget<Text>(find.text('ليل'));

    expect(find.byType(FittedBox), findsNothing);
    expect(dayText.style?.fontSize, 22);
    expect(dayText.textDirection, TextDirection.rtl);
    expect(nightText.style?.fontSize, 24);
    expect(nightText.textDirection, TextDirection.rtl);
  });

  testWidgets('progress does not reverse after reaching the target edge', (
    tester,
  ) async {
    var value = LiquidGlassSwitchValue.light;
    final progressSamples = <double>[];

    await tester.pumpWidget(
      buildHarness(
        value: value,
        onChanged: (_) {},
        onPositionChanged: progressSamples.add,
      ),
    );

    value = LiquidGlassSwitchValue.dark;
    await tester.pumpWidget(
      buildHarness(
        value: value,
        onChanged: (_) {},
        onPositionChanged: progressSamples.add,
      ),
    );
    await tester.pumpAndSettle();

    expect(progressSamples, isNotEmpty);

    var hitEdge = false;
    for (final sample in progressSamples) {
      if (sample >= 0.98) {
        hitEdge = true;
      }
      if (hitEdge) {
        expect(sample, greaterThanOrEqualTo(0.98));
      }
    }
  });

  testWidgets('track stays plain while label slot stays separate from orb', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(value: LiquidGlassSwitchValue.dark, onChanged: (_) {}),
    );

    final darkColor = trackBaseColor(tester);
    final darkLabelRect = tester.getRect(find.byKey(leftLabelSlotKey));
    final darkOrbRect = tester.getRect(find.byKey(orbSlotKey));

    await tester.pumpWidget(
      buildHarness(value: LiquidGlassSwitchValue.light, onChanged: (_) {}),
    );
    await tester.pumpAndSettle();

    final lightColor = trackBaseColor(tester);
    final labelSlot = tester.getSize(find.byKey(labelSlotKey));
    final lightLabelRect = tester.getRect(find.byKey(rightLabelSlotKey));
    final lightOrbRect = tester.getRect(find.byKey(orbSlotKey));

    expect(lightColor.toARGB32(), darkColor.toARGB32());
    expect(labelSlot.width, greaterThan(80));
    expect(labelOpacity(tester, leftLabelOpacityKey), roughlyHidden());
    expect(labelOpacity(tester, rightLabelOpacityKey), roughlyVisible());
    expect(darkLabelRect.right, lessThanOrEqualTo(darkOrbRect.left));
    expect(lightLabelRect.left, greaterThanOrEqualTo(lightOrbRect.right));
  });

  testWidgets('labels fade between fixed left and right slots only', (
    tester,
  ) async {
    var value = LiquidGlassSwitchValue.light;

    await tester.pumpWidget(buildHarness(value: value, onChanged: (_) {}));

    final initialLeftRect = tester.getRect(find.byKey(leftLabelSlotKey));
    final initialRightRect = tester.getRect(find.byKey(rightLabelSlotKey));

    value = LiquidGlassSwitchValue.dark;
    await tester.pumpWidget(buildHarness(value: value, onChanged: (_) {}));

    var sawIntermediateFade = false;
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 40));

      expect(tester.getRect(find.byKey(leftLabelSlotKey)), initialLeftRect);
      expect(tester.getRect(find.byKey(rightLabelSlotKey)), initialRightRect);

      final leftOpacity = labelOpacity(tester, leftLabelOpacityKey);
      final rightOpacity = labelOpacity(tester, rightLabelOpacityKey);
      final leftIsIntermediate = leftOpacity > 0.001 && leftOpacity < 0.999;
      final rightIsIntermediate = rightOpacity > 0.001 && rightOpacity < 0.999;
      if (leftIsIntermediate || rightIsIntermediate) {
        sawIntermediateFade = true;
        break;
      }
    }

    expect(sawIntermediateFade, isTrue);
  });

  testWidgets('track color remains stable during animation', (tester) async {
    var value = LiquidGlassSwitchValue.dark;

    await tester.pumpWidget(buildHarness(value: value, onChanged: (_) {}));

    final darkColor = trackBaseColor(tester);

    value = LiquidGlassSwitchValue.light;
    await tester.pumpWidget(buildHarness(value: value, onChanged: (_) {}));
    await tester.pump(const Duration(milliseconds: 70));
    final midColor = trackBaseColor(tester);

    await tester.pumpAndSettle();
    final lightColor = trackBaseColor(tester);

    expect(midColor.toARGB32(), darkColor.toARGB32());
    expect(midColor.toARGB32(), lightColor.toARGB32());
  });
}
