part of 'liquid_glass_switch.dart';

enum LiquidGlassSwitchValue { light, dark }

enum LiquidGlassLabelFit { scaleDown, fixed }

@immutable
class LiquidGlassIconGlow {
  const LiquidGlassIconGlow({
    this.color = Colors.white,
    this.opacity = 0.55,
    this.blur = 20.0,
    this.spread = 2.0,
    this.offset = Offset.zero,
  }) : assert(opacity >= 0 && opacity <= 1),
       assert(blur >= 0),
       assert(spread >= 0);

  final Color color;
  final double opacity;
  final double blur;
  final double spread;
  final Offset offset;
}

@immutable
class LiquidGlassStateContent {
  const LiquidGlassStateContent({
    required this.label,
    required this.icon,
    required this.tint,
    this.iconGlow = const LiquidGlassIconGlow(),
    this.iconColor,
    this.iconSize,
    this.labelStyle,
    this.labelFit = LiquidGlassLabelFit.scaleDown,
    this.labelTextDirection,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final LiquidGlassIconGlow iconGlow;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? labelStyle;
  final LiquidGlassLabelFit labelFit;
  final TextDirection? labelTextDirection;
}

@immutable
class LiquidGlassSwitchContent {
  const LiquidGlassSwitchContent({required this.left, required this.right});

  const LiquidGlassSwitchContent.darkLight()
    : left = const LiquidGlassStateContent(
        label: 'Light',
        icon: Icons.light_mode_rounded,
        tint: Color(0xFFFFFFFF),
        iconGlow: LiquidGlassIconGlow(opacity: 0.40, blur: 16, spread: 0.8),
      ),
      right = const LiquidGlassStateContent(
        label: 'Dark',
        icon: Icons.dark_mode_rounded,
        tint: Color(0xFFFFFFFF),
        iconGlow: LiquidGlassIconGlow(opacity: 0.65, blur: 24, spread: 2.0),
      );

  final LiquidGlassStateContent left;
  final LiquidGlassStateContent right;
}

@immutable
class LiquidGlassShadowStyle {
  const LiquidGlassShadowStyle({
    required this.offset,
    required this.blur,
    required this.spread,
    required this.color,
  }) : assert(blur >= 0);

  final Offset offset;
  final double blur;
  final double spread;
  final Color color;
}

@immutable
class LiquidGlassGeometryStyle {
  const LiquidGlassGeometryStyle({
    this.trackWidth = 250.0,
    this.trackHeight = 92.0,
    this.orbSize = 132.0,
    this.indicatorWidth,
    this.indicatorHeight,
    this.orbOverflow = 16.0,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 28.0),
    this.labelSafeZone = 82.0,
    this.enforceOrbLabelClearance = true,
  }) : assert(trackWidth > 0),
       assert(trackHeight > 0),
       assert(orbSize > 0),
       assert(indicatorWidth == null || indicatorWidth > 0),
       assert(indicatorHeight == null || indicatorHeight > 0),
       assert(orbOverflow >= 0),
       assert(labelSafeZone >= 0);

  final double trackWidth;
  final double trackHeight;
  final double orbSize;
  final double? indicatorWidth;
  final double? indicatorHeight;
  final double orbOverflow;
  final EdgeInsets labelPadding;
  final double labelSafeZone;
  final bool enforceOrbLabelClearance;

  double get totalWidth => trackWidth + (orbOverflow * 2);
  double get totalHeight => math.max(trackHeight, orbHeight);
  double get trackTop => (totalHeight - trackHeight) / 2;
  double get orbTop => (totalHeight - orbHeight) / 2;
  double get orbWidth => indicatorWidth ?? orbSize * 0.92;
  double get orbHeight => indicatorHeight ?? orbSize * 1.30;
  double get effectiveLabelSafeZone => enforceOrbLabelClearance
      ? math.max(labelSafeZone, orbWidth * 0.72)
      : labelSafeZone;
}

@immutable
class LiquidGlassGlassStyle {
  const LiquidGlassGlassStyle({
    this.refraction = 100.0,
    this.depth = 50.0,
    this.dispersion = 100.0,
    this.frost = 0.0,
    this.lightAngle = -45.0,
    this.lightIntensity = 100.0,
  }) : assert(refraction >= 0),
       assert(depth >= 0),
       assert(dispersion >= 0),
       assert(frost >= 0),
       assert(lightIntensity >= 0);

  final double refraction;
  final double depth;
  final double dispersion;
  final double frost;
  final double lightAngle;
  final double lightIntensity;
}

@immutable
class LiquidGlassTrackStyle {
  const LiquidGlassTrackStyle({
    this.baseColor = const Color(0xFF1E2021),
    this.baseOpacity = 1.0,
    this.borderColor = const Color(0x00000000),
    this.borderWidth = 0.0,
    this.fallbackBlur = 16.0,
    this.dropShadow = const LiquidGlassShadowStyle(
      offset: Offset(-20, 100),
      blur: 180,
      spread: 0,
      color: Color(0xFF1E2021),
    ),
    this.innerShadow = const LiquidGlassShadowStyle(
      offset: Offset(-2, -4),
      blur: 4,
      spread: 0,
      color: Color(0x59000000),
    ),
    this.innerHighlight = const LiquidGlassShadowStyle(
      offset: Offset(0, 2),
      blur: 10,
      spread: 0,
      color: Color(0x40FFFFFF),
    ),
    this.surfaceGradient = const [
      Color(0xFF26282B),
      Color(0xFF1E2021),
      Color(0xFF1B1D1F),
    ],
    this.topSheenGradient = const [Color(0x00FFFFFF), Color(0x00FFFFFF)],
    this.topSheenHeight = 0.0,
    this.topSheenInset = 0.0,
    this.refractionScale = 0.18,
    this.depthScale = 0.30,
    this.dispersionScale = 0.20,
  }) : assert(baseOpacity >= 0 && baseOpacity <= 1),
       assert(borderWidth >= 0),
       assert(fallbackBlur >= 0),
       assert(topSheenHeight >= 0),
       assert(topSheenInset >= 0),
       assert(refractionScale >= 0),
       assert(depthScale >= 0),
       assert(dispersionScale >= 0);

  final Color baseColor;
  final double baseOpacity;
  final Color borderColor;
  final double borderWidth;
  final double fallbackBlur;
  final LiquidGlassShadowStyle dropShadow;
  final LiquidGlassShadowStyle innerShadow;
  final LiquidGlassShadowStyle innerHighlight;
  final List<Color> surfaceGradient;
  final List<Color> topSheenGradient;
  final double topSheenHeight;
  final double topSheenInset;
  final double refractionScale;
  final double depthScale;
  final double dispersionScale;
}

@immutable
class LiquidGlassOrbStyle {
  const LiquidGlassOrbStyle({
    this.baseColor = const Color(0xFFFFFFFF),
    this.baseOpacity = 0.0,
    this.borderColor = const Color(0x55FFFFFF),
    this.borderWidth = 1.0,
    this.fallbackBlur = 14.0,
    this.dropShadow = const LiquidGlassShadowStyle(
      offset: Offset(0, 22),
      blur: 58,
      spread: -8,
      color: Color(0x66303C4A),
    ),
    this.surfaceGradient = const [
      Color(0x08FFFFFF),
      Color(0x03FFFFFF),
      Color(0x01000000),
    ],
    this.tintMix = 0.0,
    this.topSheenGradient = const [Color(0x00FFFFFF), Color(0x00FFFFFF)],
    this.topSheenHeight = 0.0,
    this.topSheenInset = 16.0,
    this.bottomSheenGradient = const [Color(0x00FFFFFF), Color(0x08FFFFFF)],
    this.bottomSheenHeight = 8.0,
    this.bottomSheenInset = 18.0,
    this.refractionScale = 0.88,
    this.depthScale = 0.92,
    this.dispersionScale = 0.82,
    this.iconColor = Colors.white,
    this.iconSize = 50.0,
  }) : assert(baseOpacity >= 0 && baseOpacity <= 1),
       assert(borderWidth >= 0),
       assert(fallbackBlur >= 0),
       assert(tintMix >= 0 && tintMix <= 1),
       assert(topSheenHeight >= 0),
       assert(topSheenInset >= 0),
       assert(bottomSheenHeight >= 0),
       assert(bottomSheenInset >= 0),
       assert(refractionScale >= 0),
       assert(depthScale >= 0),
       assert(dispersionScale >= 0),
       assert(iconSize > 0);

  final Color baseColor;
  final double baseOpacity;
  final Color borderColor;
  final double borderWidth;
  final double fallbackBlur;
  final LiquidGlassShadowStyle dropShadow;
  final List<Color> surfaceGradient;
  final double tintMix;
  final List<Color> topSheenGradient;
  final double topSheenHeight;
  final double topSheenInset;
  final List<Color> bottomSheenGradient;
  final double bottomSheenHeight;
  final double bottomSheenInset;
  final double refractionScale;
  final double depthScale;
  final double dispersionScale;
  final Color iconColor;
  final double iconSize;
}

@immutable
class LiquidGlassTypographyStyle {
  const LiquidGlassTypographyStyle({
    this.textStyle = const TextStyle(
      fontSize: 46,
      fontWeight: FontWeight.w500,
      letterSpacing: -1.0,
      height: 1,
      color: Color(0xBFC8CDD6),
    ),
  });

  final TextStyle textStyle;
}

@immutable
class LiquidGlassSwitchStyle {
  const LiquidGlassSwitchStyle({
    this.geometry = const LiquidGlassGeometryStyle(),
    this.glass = const LiquidGlassGlassStyle(),
    this.track = const LiquidGlassTrackStyle(),
    this.orb = const LiquidGlassOrbStyle(),
    this.typography = const LiquidGlassTypographyStyle(),
  });

  final LiquidGlassGeometryStyle geometry;
  final LiquidGlassGlassStyle glass;
  final LiquidGlassTrackStyle track;
  final LiquidGlassOrbStyle orb;
  final LiquidGlassTypographyStyle typography;
}

@immutable
class LiquidGlassSwitchMotion {
  const LiquidGlassSwitchMotion({
    this.spring = const SpringDescription(
      mass: 1.0,
      stiffness: 300.0,
      damping: 18.0,
    ),
    this.flickThreshold = 1.5,
    this.animationDuration = const Duration(milliseconds: 260),
    this.contentDuration = const Duration(milliseconds: 240),
    this.bounceDuration = const Duration(milliseconds: 420),
    this.bounceAmplitude = 12.0,
    this.bounceCycles = 1.0,
    this.bounceDamping = 3.4,
  }) : assert(flickThreshold >= 0),
       assert(bounceAmplitude >= 0),
       assert(bounceCycles > 0),
       assert(bounceDamping >= 0);

  final SpringDescription spring;
  final double flickThreshold;
  final Duration animationDuration;
  final Duration contentDuration;
  final Duration bounceDuration;
  final double bounceAmplitude;
  final double bounceCycles;
  final double bounceDamping;
}
