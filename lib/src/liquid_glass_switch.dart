import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

const double _defaultWidth = 200.0;
const double _trackHeight = 58.0;
const double _orbSize = 82.0;
const double _switchHeight = 104.0;

const String _packageShaderAsset =
    'packages/liquid_glass_switch/shaders/liquid_glass.frag';
const String _localShaderAsset = 'shaders/liquid_glass.frag';

@immutable
class LiquidGlassSwitchFace {
  const LiquidGlassSwitchFace({
    required this.label,
    required this.icon,
    required this.tint,
  });

  final String label;
  final IconData icon;
  final Color tint;

  static const LiquidGlassSwitchFace work = LiquidGlassSwitchFace(
    label: 'Work',
    icon: Icons.person_rounded,
    tint: Color(0xFFFFD45F),
  );

  static const LiquidGlassSwitchFace sleep = LiquidGlassSwitchFace(
    label: 'Sleep',
    icon: Icons.nightlight_round,
    tint: Color(0xFF8B8EFF),
  );
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
    this.duration = const Duration(milliseconds: 220),
  }) : assert(flickThreshold >= 0);

  final SpringDescription spring;
  final double flickThreshold;
  final Duration duration;
}

class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.leftFace = LiquidGlassSwitchFace.work,
    this.rightFace = LiquidGlassSwitchFace.sleep,
    this.width = _defaultWidth,
    this.enabled = true,
    this.motion = const LiquidGlassSwitchMotion(),
  }) : assert(width > _orbSize);

  final bool value;
  final ValueChanged<bool> onChanged;
  final LiquidGlassSwitchFace leftFace;
  final LiquidGlassSwitchFace rightFace;
  final double width;
  final bool enabled;
  final LiquidGlassSwitchMotion motion;

  @override
  State<LiquidGlassSwitch> createState() => _LiquidGlassSwitchState();
}

class _LiquidGlassSwitchState extends State<LiquidGlassSwitch>
    with SingleTickerProviderStateMixin {
  static Future<FragmentProgram?>? _programFuture;

  late final AnimationController _controller;
  FragmentShader? _trackShader;
  FragmentShader? _orbShader;

  double get _draggableDistance => widget.width - _orbSize;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: _valueToController(widget.value),
      duration: widget.motion.duration,
    );
    _loadShader();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.motion.duration != widget.motion.duration) {
      _controller.duration = widget.motion.duration;
    }

    if (oldWidget.value != widget.value) {
      _controller.animateTo(
        _valueToController(widget.value),
        duration: widget.motion.duration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadShader() async {
    final program = await (_programFuture ??= _resolveProgram());
    if (!mounted || program == null) {
      return;
    }

    setState(() {
      _trackShader = program.fragmentShader();
      _orbShader = program.fragmentShader();
    });
  }

  static Future<FragmentProgram?> _resolveProgram() async {
    try {
      return await FragmentProgram.fromAsset(_packageShaderAsset);
    } catch (_) {
      try {
        return await FragmentProgram.fromAsset(_localShaderAsset);
      } catch (_) {
        return null;
      }
    }
  }

  static double _valueToController(bool value) => value ? 1.0 : 0.0;

  void _animateWithSpring(double target, double velocity) {
    final simulation = SpringSimulation(
      widget.motion.spring,
      _controller.value,
      target,
      velocity,
    );
    _controller.animateWith(simulation);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || details.primaryDelta == null) {
      return;
    }

    final nextValue =
        _controller.value + (details.primaryDelta! / _draggableDistance);
    _controller.value = nextValue.clamp(0.0, 1.0);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled) {
      return;
    }

    final dragVelocity = (details.primaryVelocity ?? 0.0) / _draggableDistance;
    final target = dragVelocity.abs() > widget.motion.flickThreshold
        ? (dragVelocity > 0 ? 1.0 : 0.0)
        : (_controller.value > 0.5 ? 1.0 : 0.0);

    _animateWithSpring(target, dragVelocity);

    final nextValue = target >= 0.5;
    if (nextValue != widget.value) {
      widget.onChanged(nextValue);
    }
  }

  void _onTap() {
    if (!widget.enabled) {
      return;
    }

    final nextValue = !widget.value;
    _animateWithSpring(_valueToController(nextValue), 0.0);
    widget.onChanged(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      enabled: widget.enabled,
      toggled: widget.value,
      label: 'Liquid glass switch',
      value: widget.value ? widget.rightFace.label : widget.leftFace.label,
      onTap: widget.enabled ? _onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.enabled ? _onTap : null,
        onHorizontalDragUpdate: widget.enabled ? _onPanUpdate : null,
        onHorizontalDragEnd: widget.enabled ? _onPanEnd : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final rightSelected = _controller.value > 0.5;
            final activeFace = rightSelected
                ? widget.rightFace
                : widget.leftFace;

            final orbAlignment = Alignment(
              lerpDouble(-1.0, 1.0, _controller.value)!,
              0.0,
            );

            final textAlignment = Alignment(
              lerpDouble(1.0, -1.0, _controller.value)!,
              0.0,
            );

            final leftPadding = lerpDouble(88.0, 30.0, _controller.value)!;
            final rightPadding = lerpDouble(30.0, 88.0, _controller.value)!;

            return Opacity(
              opacity: widget.enabled ? 1.0 : 0.72,
              child: SizedBox(
                width: widget.width,
                height: _switchHeight,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 23,
                      child: _GlassTrack(
                        width: widget.width,
                        height: _trackHeight,
                        shader: _trackShader,
                        tint: activeFace.tint,
                        child: Align(
                          alignment: textAlignment,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: leftPadding,
                              right: rightPadding,
                            ),
                            child: AnimatedSwitcher(
                              duration: widget.motion.duration,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.97, end: 1.0)
                                        .animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                activeFace.label,
                                key: ValueKey(activeFace.label),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.6,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: orbAlignment,
                      child: _GlassOrb(
                        size: _orbSize,
                        shader: _orbShader,
                        tint: activeFace.tint,
                        child: AnimatedSwitcher(
                          duration: widget.motion.duration,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.92, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            activeFace.icon,
                            key: ValueKey(activeFace.icon),
                            size: 34,
                            color: Colors.white.withValues(alpha: 0.98),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GlassTrack extends StatelessWidget {
  const _GlassTrack({
    required this.width,
    required this.height,
    required this.shader,
    required this.tint,
    required this.child,
  });

  final double width;
  final double height;
  final FragmentShader? shader;
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          SizedBox(
            width: width,
            height: height,
            child: shader == null
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: const SizedBox.expand(),
                  )
                : Builder(
                    builder: (context) {
                      final s = shader!;
                      _setShaderUniforms(
                        shader: s,
                        tint: tint,
                        distortion: 11.0,
                        edgeBoost: 0.42,
                        lightX: 0.28,
                        lightY: 0.16,
                      );
                      return BackdropFilter(
                        filter: ImageFilter.shader(s),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.025),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.24),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 18,
            right: 18,
            child: IgnorePointer(
              child: Container(
                height: 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlassOrb extends StatelessWidget {
  const _GlassOrb({
    required this.size,
    required this.shader,
    required this.tint,
    required this.child,
  });

  final double size;
  final FragmentShader? shader;
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: shader == null
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: const SizedBox.expand(),
                  )
                : Builder(
                    builder: (context) {
                      final s = shader!;
                      _setShaderUniforms(
                        shader: s,
                        tint: tint,
                        distortion: 26.0,
                        edgeBoost: 0.85,
                        lightX: 0.35,
                        lightY: 0.20,
                      );
                      return BackdropFilter(
                        filter: ImageFilter.shader(s),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.25, -0.25),
                    radius: 1.05,
                    colors: [
                      Colors.white.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 12,
            right: 12,
            child: IgnorePointer(
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.45),
                      Colors.white.withValues(alpha: 0.01),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

void _setShaderUniforms({
  required FragmentShader shader,
  required Color tint,
  required double distortion,
  required double edgeBoost,
  required double lightX,
  required double lightY,
}) {
  shader.setFloat(0, distortion);
  shader.setFloat(1, edgeBoost);
  shader.setFloat(2, lightX);
  shader.setFloat(3, lightY);
  shader.setFloat(4, tint.r);
  shader.setFloat(5, tint.g);
  shader.setFloat(6, tint.b);
  shader.setFloat(7, tint.a);
}
