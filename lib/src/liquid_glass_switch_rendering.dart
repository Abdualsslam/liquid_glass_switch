part of 'liquid_glass_switch.dart';

const String _packageShaderAsset =
    'packages/liquid_glass_switch/shaders/liquid_glass.frag';
const String _localShaderAsset = 'shaders/liquid_glass.frag';
const ValueKey<String> _trackBaseKey = ValueKey<String>(
  'liquid_glass_switch_track_base',
);
const ValueKey<String> _labelSlotKey = ValueKey<String>(
  'liquid_glass_switch_label_slot',
);
const ValueKey<String> _leftLabelSlotKey = ValueKey<String>(
  'liquid_glass_switch_left_label_slot',
);
const ValueKey<String> _rightLabelSlotKey = ValueKey<String>(
  'liquid_glass_switch_right_label_slot',
);
const ValueKey<String> _leftLabelOpacityKey = ValueKey<String>(
  'liquid_glass_switch_left_label_opacity',
);
const ValueKey<String> _rightLabelOpacityKey = ValueKey<String>(
  'liquid_glass_switch_right_label_opacity',
);
const ValueKey<String> _orbSlotKey = ValueKey<String>(
  'liquid_glass_switch_orb_slot',
);

class _GlassTrack extends StatelessWidget {
  const _GlassTrack({
    required this.width,
    required this.height,
    required this.style,
    required this.child,
  });

  final double width;
  final double height;
  final LiquidGlassSwitchStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    final trackStyle = style.track;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [_toBoxShadow(trackStyle.dropShadow)],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  key: _trackBaseKey,
                  color: trackStyle.baseColor.withValues(
                    alpha: trackStyle.baseOpacity,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: trackStyle.surfaceGradient,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _InsetShadowPainter(
                      borderRadius: radius,
                      shadow: trackStyle.innerShadow,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _InsetShadowPainter(
                      borderRadius: radius,
                      shadow: trackStyle.innerHighlight,
                    ),
                  ),
                ),
              ),
              if (trackStyle.topSheenHeight > 0)
                Positioned(
                  top: 6,
                  left: trackStyle.topSheenInset,
                  right: trackStyle.topSheenInset,
                  child: IgnorePointer(
                    child: Container(
                      height: trackStyle.topSheenHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: trackStyle.topSheenGradient,
                        ),
                      ),
                    ),
                  ),
                ),
              if (trackStyle.borderWidth > 0)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: trackStyle.borderColor,
                        width: trackStyle.borderWidth,
                      ),
                    ),
                  ),
                ),
              Positioned.fill(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassOrb extends StatelessWidget {
  const _GlassOrb({
    required this.width,
    required this.height,
    required this.shader,
    required this.tint,
    required this.stateProgress,
    required this.style,
    required this.iconGlow,
    required this.child,
  });

  final double width;
  final double height;
  final FragmentShader? shader;
  final Color tint;
  final double stateProgress;
  final LiquidGlassSwitchStyle style;
  final LiquidGlassIconGlow iconGlow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final orbStyle = style.orb;
    final radius = BorderRadius.circular(height / 2);
    final lightAmount = Curves.easeOutCubic.transform(1.0 - stateProgress);
    final resolvedBaseColor = orbStyle.baseColor;
    const resolvedBaseOpacity = 0.0;
    final resolvedDropShadow = _lerpShadow(
      orbStyle.dropShadow,
      const LiquidGlassShadowStyle(
        offset: Offset(0, 28),
        blur: 64,
        spread: -12,
        color: Color(0x66000000),
      ),
      0.25 + (lightAmount * 0.2),
    );
    final resolvedSurfaceGradient = orbStyle.surfaceGradient;
    final resolvedBorderColor = Color.lerp(
      orbStyle.borderColor,
      Colors.white.withValues(alpha: 0.72),
      lightAmount * 0.20,
    )!;
    final resolvedTopSheenGradient = _lerpColorList(
      orbStyle.topSheenGradient,
      const [Color(0xA0FFFFFF), Color(0x00FFFFFF)],
      lightAmount * 0.18,
    );
    final resolvedBottomSheenGradient = _lerpColorList(
      orbStyle.bottomSheenGradient,
      const [Color(0x00FFFFFF), Color(0x10FFFFFF)],
      lightAmount * 0.15,
    );
    final boxShadows = <BoxShadow>[
      _toBoxShadow(resolvedDropShadow),
      if (lightAmount > 0.01)
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.05 * lightAmount),
          blurRadius: 24 + (12 * lightAmount),
          spreadRadius: -10,
          offset: const Offset(0, 2),
        ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: boxShadows),
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: shader == null
                    ? BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: orbStyle.fallbackBlur,
                          sigmaY: orbStyle.fallbackBlur,
                        ),
                        child: const SizedBox.expand(),
                      )
                    : Builder(
                        builder: (context) {
                          final s = shader!;
                          _setShaderUniforms(
                            shader: s,
                            glass: style.glass,
                            tint: tint,
                            refractionScale: orbStyle.refractionScale,
                            depthScale: orbStyle.depthScale,
                            dispersionScale: orbStyle.dispersionScale,
                          );
                          return _shaderBackdropOrFallback(
                            shader: s,
                            fallbackBlur: orbStyle.fallbackBlur,
                          );
                        },
                      ),
              ),
              Positioned.fill(
                child: ColoredBox(
                  color: resolvedBaseColor.withValues(
                    alpha: resolvedBaseOpacity,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: RadialGradient(
                      center: const Alignment(-0.15, -0.15),
                      radius: 1.08,
                      colors: [
                        resolvedSurfaceGradient[0],
                        Color.lerp(
                          resolvedSurfaceGradient[1],
                          tint,
                          orbStyle.tintMix,
                        )!,
                        resolvedSurfaceGradient[2],
                      ],
                      stops: const [0.0, 0.48, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: RadialGradient(
                      center: const Alignment(0.0, 0.35),
                      radius: 0.95,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.015),
                      ],
                      stops: const [0.0, 0.72, 1.0],
                    ),
                  ),
                ),
              ),
              if (orbStyle.topSheenHeight > 0)
                Positioned(
                  top: 8,
                  left: orbStyle.topSheenInset,
                  right: orbStyle.topSheenInset,
                  child: IgnorePointer(
                    child: Container(
                      height: orbStyle.topSheenHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            resolvedTopSheenGradient[0],
                            resolvedTopSheenGradient[1],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (orbStyle.bottomSheenHeight > 0)
                Positioned(
                  bottom: 10,
                  left: orbStyle.bottomSheenInset,
                  right: orbStyle.bottomSheenInset,
                  child: IgnorePointer(
                    child: Container(
                      height: orbStyle.bottomSheenHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            resolvedBottomSheenGradient[0],
                            resolvedBottomSheenGradient[1],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: resolvedBorderColor,
                      width: orbStyle.borderWidth,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(child: const SizedBox.expand()),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconGlow.color.withValues(alpha: iconGlow.opacity),
                      blurRadius: iconGlow.blur,
                      spreadRadius: iconGlow.spread,
                      offset: iconGlow.offset,
                    ),
                  ],
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsetShadowPainter extends CustomPainter {
  const _InsetShadowPainter({required this.borderRadius, required this.shadow});

  final BorderRadius borderRadius;
  final LiquidGlassShadowStyle shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = borderRadius.toRRect(rect);
    final inset = math.max(1.0, shadow.blur * 1.2);
    final strokeRRect = borderRadius.toRRect(rect.deflate(inset / 2));
    canvas.save();
    canvas.clipRRect(rRect);
    canvas.translate(shadow.offset.dx, shadow.offset.dy);
    canvas.drawRRect(
      strokeRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = inset
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          _blurSigma(shadow.blur),
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InsetShadowPainter oldDelegate) =>
      borderRadius != oldDelegate.borderRadius || shadow != oldDelegate.shadow;
}

void _setShaderUniforms({
  required FragmentShader shader,
  required LiquidGlassGlassStyle glass,
  required Color tint,
  required double refractionScale,
  required double depthScale,
  required double dispersionScale,
}) {
  shader.setFloat(0, glass.refraction * refractionScale);
  shader.setFloat(1, glass.depth * depthScale);
  shader.setFloat(2, glass.dispersion * dispersionScale);
  shader.setFloat(3, glass.frost);
  shader.setFloat(4, glass.lightAngle * math.pi / 180);
  shader.setFloat(5, glass.lightIntensity);
  shader.setFloat(6, tint.r);
  shader.setFloat(7, tint.g);
  shader.setFloat(8, tint.b);
  shader.setFloat(9, tint.a);
}

BoxShadow _toBoxShadow(LiquidGlassShadowStyle shadow) {
  return BoxShadow(
    color: shadow.color,
    offset: shadow.offset,
    blurRadius: shadow.blur,
    spreadRadius: shadow.spread,
  );
}

List<Color> _lerpColorList(List<Color> a, List<Color> b, double t) {
  final clamped = t.clamp(0.0, 1.0).toDouble();
  final length = math.min(a.length, b.length);
  return List<Color>.generate(
    length,
    (index) => Color.lerp(a[index], b[index], clamped)!,
  );
}

LiquidGlassShadowStyle _lerpShadow(
  LiquidGlassShadowStyle a,
  LiquidGlassShadowStyle b,
  double t,
) {
  final clamped = t.clamp(0.0, 1.0).toDouble();
  return LiquidGlassShadowStyle(
    offset: Offset.lerp(a.offset, b.offset, clamped)!,
    blur: lerpDouble(a.blur, b.blur, clamped)!,
    spread: lerpDouble(a.spread, b.spread, clamped)!,
    color: Color.lerp(a.color, b.color, clamped)!,
  );
}

Widget _shaderBackdropOrFallback({
  required FragmentShader shader,
  required double fallbackBlur,
}) {
  try {
    return BackdropFilter(
      filter: ImageFilter.shader(shader),
      child: const SizedBox.expand(),
    );
  } on UnsupportedError {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: fallbackBlur, sigmaY: fallbackBlur),
      child: const SizedBox.expand(),
    );
  }
}

double _blurSigma(double radius) => radius <= 0 ? 0 : radius * 0.57735 + 0.5;
