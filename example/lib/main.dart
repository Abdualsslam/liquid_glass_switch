import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_switch/liquid_glass_switch.dart';

void main() {
  runApp(const LiquidGlassSwitchExampleApp());
}

class LiquidGlassSwitchExampleApp extends StatelessWidget {
  const LiquidGlassSwitchExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const _DemoPage(),
    );
  }
}

class _DemoPage extends StatefulWidget {
  const _DemoPage();

  @override
  State<_DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<_DemoPage> {
  static const LiquidGlassSwitchContent _customContent =
      LiquidGlassSwitchContent(
        left: LiquidGlassStateContent(
          label: 'Light',
          icon: Icons.wb_sunny_rounded,
          tint: Colors.white,
          iconGlow: LiquidGlassIconGlow(
            color: Colors.white,
            opacity: 0.0,
            blur: 0,
            spread: 0,
          ),
          iconColor: Colors.white,
          iconSize: 34,
          labelFit: LiquidGlassLabelFit.fixed,
          labelTextDirection: TextDirection.rtl,
          labelStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.1,
            color: Colors.white,
          ),
        ),
        right: LiquidGlassStateContent(
          label: 'Dark',
          icon: Icons.dark_mode_rounded,
          tint: Colors.white,
          iconGlow: LiquidGlassIconGlow(
            color: Color(0xFFD6E1FF),
            opacity: 0.0,
            blur: 0,
            spread: 0,
          ),
          iconColor: Color(0xFFDCE6FF),
          iconSize: 36,
          labelFit: LiquidGlassLabelFit.fixed,
          labelTextDirection: TextDirection.rtl,
          labelStyle: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.1,
            color: Colors.white,
          ),
        ),
      );

  static const LiquidGlassSwitchStyle _customStyle = LiquidGlassSwitchStyle(
    geometry: LiquidGlassGeometryStyle(
      trackWidth: 190,
      trackHeight: 77,
      orbSize: 100,
      indicatorWidth: 108,
      indicatorHeight: 125,
      orbOverflow: 24,
      labelPadding: EdgeInsets.symmetric(horizontal: 22),
      labelSafeZone: 44,
      enforceOrbLabelClearance: false,
    ),
    track: LiquidGlassTrackStyle(
      baseColor: Color(0xFF202224),
      surfaceGradient: [Color(0xFF202224), Color(0xFF202224)],
      dropShadow: LiquidGlassShadowStyle(
        offset: Offset(-10, 20),
        blur: 40,
        spread: 0,
        color: Color(0xFF1E2021),
      ),
      innerShadow: LiquidGlassShadowStyle(
        offset: Offset(-1, -1),
        blur: 2,
        spread: 0,
        color: Color(0x59000000),
      ),
      innerHighlight: LiquidGlassShadowStyle(
        offset: Offset(0, 2),
        blur: 1,
        spread: 0,
        color: Color(0x40FFFFFF),
      ),
    ),
    orb: LiquidGlassOrbStyle(iconColor: Color(0xFFFFFFFF), iconSize: 32),
    typography: LiquidGlassTypographyStyle(
      textStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.1,
        color: Colors.white,
      ),
    ),
  );

  LiquidGlassSwitchValue _value = LiquidGlassSwitchValue.dark;
  double _progress = 1.0;

  Color _lerp(Color light, Color dark) => Color.lerp(light, dark, _progress)!;

  @override
  Widget build(BuildContext context) {
    final backgroundTop = _lerp(
      const Color(0xFFC7C8CC),
      const Color(0xFF3B3F47),
    );
    final backgroundMid = _lerp(
      const Color(0xFFB8BABF),
      const Color(0xFF343942),
    );
    final backgroundBottom = _lerp(
      const Color(0xFF676A70),
      const Color(0xFF2B3038),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundTop, backgroundMid, backgroundBottom],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Transform.translate(
                offset: const Offset(0, 12),
                child: LiquidGlassSwitch(
                  value: _value,
                  content: _customContent,
                  style: _customStyle,
                  onPositionChanged: (progress) {
                    if ((_progress - progress).abs() < 0.001) {
                      return;
                    }
                    setState(() {
                      _progress = progress;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _value = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
