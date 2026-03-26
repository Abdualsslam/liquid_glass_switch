# liquid_glass_switch

A Flutter switch component with a dark/light liquid-glass style, shader-based refraction, spring interaction, and a full style-object API.

## Features

- Controlled state with `LiquidGlassSwitchValue.light` / `LiquidGlassSwitchValue.dark`
- Drag and tap interactions with spring physics
- Edge rebound (bounce) for orb settle to mimic reference motion
- Style-object customization for geometry, track, orb, glass controls, and typography
- Per-state content (`label`, `icon`, `tint`, `iconGlow`)
- Optional `onPositionChanged` callback to drive external animations (for example: background transitions)
- Shader fallback path when runtime shader loading is unavailable
- Example app with the final dark/light visual style

## Installation

```yaml
dependencies:
  liquid_glass_switch: ^1.0.0
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:liquid_glass_switch/liquid_glass_switch.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  LiquidGlassSwitchValue value = LiquidGlassSwitchValue.dark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LiquidGlassSwitch(
        value: value,
        onChanged: (next) => setState(() => value = next),
      ),
    );
  }
}
```

## Custom content and style

```dart
LiquidGlassSwitch(
  value: value,
  onChanged: (next) => setState(() => value = next),
  onPositionChanged: (progress) {
    // progress: 0.0 (light/left) -> 1.0 (dark/right)
  },
  content: const LiquidGlassSwitchContent(
    left: LiquidGlassStateContent(
      label: 'Light',
      icon: Icons.light_mode_rounded,
      tint: Color(0xFF8AAED9),
    ),
    right: LiquidGlassStateContent(
      label: 'Dark',
      icon: Icons.dark_mode_rounded,
      tint: Color(0xFF4F648A),
    ),
  ),
  style: const LiquidGlassSwitchStyle(
    geometry: LiquidGlassGeometryStyle(
      width: 260,
      trackHeight: 96,
      orbSize: 136,
      orbOverflow: 16,
    ),
    glass: LiquidGlassGlassStyle(
      refraction: 100,
      depth: 50,
      dispersion: 100,
      frost: 0,
      lightAngle: -45,
      lightIntensity: 100,
    ),
  ),
  motion: const LiquidGlassSwitchMotion(
    bounceAmplitude: 12,
    bounceCycles: 2,
    bounceDamping: 3.4,
  ),
)
```

## Migration from <= 0.1.x

- `bool value` -> `LiquidGlassSwitchValue value`
- `ValueChanged<bool>` -> `ValueChanged<LiquidGlassSwitchValue>`
- `leftFace/rightFace` -> `content.left/content.right` via `LiquidGlassSwitchContent`
- Visual configuration moved to `LiquidGlassSwitchStyle` and nested style objects

## Run example

```bash
cd example
flutter run
```

## License

MIT
