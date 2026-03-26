import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

part 'liquid_glass_switch_models.dart';
part 'liquid_glass_switch_rendering.dart';

class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.content = const LiquidGlassSwitchContent.darkLight(),
    this.style = const LiquidGlassSwitchStyle(),
    this.motion = const LiquidGlassSwitchMotion(),
    this.enabled = true,
    this.onPositionChanged,
  });

  final LiquidGlassSwitchValue value;
  final ValueChanged<LiquidGlassSwitchValue> onChanged;
  final LiquidGlassSwitchContent content;
  final LiquidGlassSwitchStyle style;
  final LiquidGlassSwitchMotion motion;
  final bool enabled;
  final ValueChanged<double>? onPositionChanged;

  @override
  State<LiquidGlassSwitch> createState() => _LiquidGlassSwitchState();
}

class _LiquidGlassSwitchState extends State<LiquidGlassSwitch>
    with TickerProviderStateMixin {
  static Future<FragmentProgram?>? _programFuture;

  late final AnimationController _controller;
  late final AnimationController _bounceController;
  FragmentShader? _orbShader;
  double _bounceDirection = 1.0;
  double _bounceVelocityBoost = 0.0;
  double _lastReportedProgress = 0.0;

  LiquidGlassGeometryStyle get _geometry => widget.style.geometry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: _valueToUnit(widget.value),
      duration: widget.motion.animationDuration,
    );
    _lastReportedProgress = _controller.value.clamp(0.0, 1.0);
    _controller.addListener(_reportProgress);
    _bounceController = AnimationController(
      vsync: this,
      duration: widget.motion.bounceDuration,
    );
    _loadShader();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion.animationDuration != widget.motion.animationDuration) {
      _controller.duration = widget.motion.animationDuration;
    }
    if (oldWidget.motion.bounceDuration != widget.motion.bounceDuration) {
      _bounceController.duration = widget.motion.bounceDuration;
    }

    if (oldWidget.value != widget.value) {
      final target = _valueToUnit(widget.value);
      if ((_controller.value - target).abs() > 0.001) {
        _animateWithSpring(target, 0.0);
      } else {
        _controller.value = target;
      }
    }

    if (oldWidget.onPositionChanged != widget.onPositionChanged) {
      _reportProgress(force: true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_reportProgress);
    _bounceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  double get _orbStartX => 0.0;
  double get _orbEndX =>
      _geometry.trackWidth - _geometry.orbWidth + (_geometry.orbOverflow * 2);
  double get _draggableDistance => math.max(_orbEndX - _orbStartX, 1.0);

  Future<void> _loadShader() async {
    final program = await (_programFuture ??= _resolveProgram());
    if (!mounted || program == null) {
      return;
    }

    setState(() {
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

  static double _valueToUnit(LiquidGlassSwitchValue value) =>
      value == LiquidGlassSwitchValue.dark ? 1.0 : 0.0;

  static LiquidGlassSwitchValue _unitToValue(double value) =>
      value >= 0.5 ? LiquidGlassSwitchValue.dark : LiquidGlassSwitchValue.light;

  LiquidGlassStateContent _contentFromUnit(double value) =>
      value >= 0.5 ? widget.content.right : widget.content.left;

  void _reportProgress({bool force = false}) {
    final callback = widget.onPositionChanged;
    if (callback == null) {
      return;
    }

    final progress = _controller.value.clamp(0.0, 1.0);
    if (force || (progress - _lastReportedProgress).abs() > 0.0005) {
      _lastReportedProgress = progress;
      callback(progress);
    }
  }

  void _startBounce({required double direction, required double velocity}) {
    _bounceDirection = direction;
    _bounceVelocityBoost = (velocity.abs() * 0.32).clamp(0.0, 0.42);
    _bounceController
      ..stop()
      ..value = 0.0
      ..forward();
  }

  double _bounceOffset(double baseProgress) {
    if (_bounceController.value <= 0) {
      return 0.0;
    }

    final edgeDistance = math.min(baseProgress, 1.0 - baseProgress);
    final edgeFactor = (1.0 - (edgeDistance / 0.2)).clamp(0.0, 1.0);
    if (edgeFactor <= 0) {
      return 0.0;
    }

    final t = _bounceController.value;
    final wave = math.sin(t * math.pi * widget.motion.bounceCycles);
    final envelope = math.exp(-widget.motion.bounceDamping * t);
    final amplitude =
        widget.motion.bounceAmplitude *
        (1.0 + _bounceVelocityBoost) *
        edgeFactor;
    return _bounceDirection * wave * envelope * amplitude;
  }

  void _animateWithSpring(double target, double velocity) {
    final start = _controller.value;
    if ((start - target).abs() <= 0.001) {
      _controller.value = target;
      return;
    }

    final movingForward = target > start;
    final simulation = SpringSimulation(
      widget.motion.spring,
      start,
      target,
      velocity,
    );
    var clampedAtTarget = false;
    late VoidCallback clampListener;
    clampListener = () {
      if (clampedAtTarget) {
        return;
      }

      final reachedTarget = movingForward
          ? _controller.value >= target
          : _controller.value <= target;
      if (!reachedTarget) {
        return;
      }

      clampedAtTarget = true;
      _controller.removeListener(clampListener);
      _controller
        ..stop()
        ..value = target;
      _startBounce(direction: target >= 0.5 ? 1.0 : -1.0, velocity: velocity);
    };

    _controller.addListener(clampListener);
    _controller.animateWith(simulation).whenCompleteOrCancel(() {
      _controller.removeListener(clampListener);
      if (!mounted) {
        return;
      }
      if (clampedAtTarget) {
        return;
      }
      final atTarget = (_controller.value - target).abs() <= 0.06;
      if (atTarget) {
        _controller.value = target;
        _startBounce(direction: target >= 0.5 ? 1.0 : -1.0, velocity: velocity);
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled) {
      return;
    }
    _bounceVelocityBoost = 0.0;
    _bounceController
      ..stop()
      ..value = 0.0;
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

    final velocity = (details.primaryVelocity ?? 0.0) / _draggableDistance;
    final target = velocity.abs() > widget.motion.flickThreshold
        ? (velocity > 0 ? 1.0 : 0.0)
        : (_controller.value > 0.5 ? 1.0 : 0.0);

    _animateWithSpring(target, velocity);
    final targetValue = _unitToValue(target);
    if (targetValue != widget.value) {
      widget.onChanged(targetValue);
    }
  }

  void _onTap() {
    if (!widget.enabled) {
      return;
    }

    final targetValue = widget.value == LiquidGlassSwitchValue.dark
        ? LiquidGlassSwitchValue.light
        : LiquidGlassSwitchValue.dark;
    _bounceVelocityBoost = 0.0;
    _animateWithSpring(_valueToUnit(targetValue), 0.0);
    widget.onChanged(targetValue);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      enabled: widget.enabled,
      toggled: widget.value == LiquidGlassSwitchValue.dark,
      value: widget.value.name,
      label: 'Liquid glass switch',
      onTap: widget.enabled ? _onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.enabled ? _onTap : null,
        onHorizontalDragStart: widget.enabled ? _onPanStart : null,
        onHorizontalDragUpdate: widget.enabled ? _onPanUpdate : null,
        onHorizontalDragEnd: widget.enabled ? _onPanEnd : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller, _bounceController]),
          builder: (context, _) {
            final progress = _controller.value.clamp(0.0, 1.0);
            final activeContent = _contentFromUnit(progress);
            final tint = Color.lerp(
              widget.content.left.tint,
              widget.content.right.tint,
              progress,
            )!;
            final baseOrbLeft = lerpDouble(_orbStartX, _orbEndX, progress)!;
            final orbLeft = baseOrbLeft + _bounceOffset(progress);
            final labelGap = math.max(12.0, _geometry.orbOverflow * 0.75);
            final labelReservedWidth =
                _geometry.effectiveLabelSafeZone + labelGap;
            final labelSlotWidth = math.max(
              0.0,
              _geometry.trackWidth -
                  _geometry.labelPadding.horizontal -
                  labelReservedWidth,
            );
            final labelFadeProgress = Curves.easeInOutCubic.transform(
              ((progress - 0.15) / 0.7).clamp(0.0, 1.0),
            );
            final leftLabelOpacity = labelFadeProgress;
            final rightLabelOpacity = 1.0 - leftLabelOpacity;
            final activeIconSize =
                activeContent.iconSize ?? widget.style.orb.iconSize;
            final activeIconColor =
                activeContent.iconColor ?? widget.style.orb.iconColor;

            Widget buildTrackLabel({
              required ValueKey<String> opacityKey,
              required Alignment alignment,
              required LiquidGlassStateContent content,
              required double opacity,
            }) {
              Widget labelChild = Text(
                content.label,
                textDirection: content.labelTextDirection,
                style: widget.style.typography.textStyle.merge(
                  content.labelStyle,
                ),
                maxLines: 1,
                overflow: content.labelFit == LiquidGlassLabelFit.scaleDown
                    ? TextOverflow.visible
                    : TextOverflow.clip,
                softWrap: false,
              );

              if (content.labelFit == LiquidGlassLabelFit.scaleDown) {
                labelChild = FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: alignment,
                  child: labelChild,
                );
              }

              return Opacity(
                key: opacityKey,
                opacity: opacity,
                child: ClipRect(
                  child: SizedBox.expand(
                    child: Align(alignment: alignment, child: labelChild),
                  ),
                ),
              );
            }

            return Opacity(
              opacity: widget.enabled ? 1.0 : 0.1,
              child: SizedBox(
                width: _geometry.totalWidth,
                height: _geometry.totalHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: _geometry.orbOverflow,
                      top: _geometry.trackTop,
                      child: _GlassTrack(
                        width: _geometry.trackWidth,
                        height: _geometry.trackHeight,
                        style: widget.style,
                        child: Stack(
                          key: _labelSlotKey,
                          children: [
                            Positioned(
                              left: _geometry.labelPadding.left,
                              top: 0,
                              bottom: 0,
                              width: labelSlotWidth,
                              child: SizedBox(
                                key: _leftLabelSlotKey,
                                width: labelSlotWidth,
                                child: buildTrackLabel(
                                  opacityKey: _leftLabelOpacityKey,
                                  alignment: Alignment.centerLeft,
                                  content: widget.content.right,
                                  opacity: leftLabelOpacity,
                                ),
                              ),
                            ),
                            Positioned(
                              right: _geometry.labelPadding.right,
                              top: 0,
                              bottom: 0,
                              width: labelSlotWidth,
                              child: SizedBox(
                                key: _rightLabelSlotKey,
                                width: labelSlotWidth,
                                child: buildTrackLabel(
                                  opacityKey: _rightLabelOpacityKey,
                                  alignment: Alignment.centerRight,
                                  content: widget.content.left,
                                  opacity: rightLabelOpacity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      key: _orbSlotKey,
                      left: orbLeft,
                      top: _geometry.orbTop,
                      child: _GlassOrb(
                        width: _geometry.orbWidth,
                        height: _geometry.orbHeight,
                        shader: _orbShader,
                        tint: tint,
                        stateProgress: progress,
                        style: widget.style,
                        iconGlow: activeContent.iconGlow,
                        child: AnimatedSwitcher(
                          duration: widget.motion.contentDuration,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.92,
                                  end: 1.2,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },

                          child: Icon(
                            key: ValueKey<String>(
                              '${activeContent.icon.codePoint}'
                              '-${activeIconSize.toStringAsFixed(2)}'
                              '-${activeIconColor.toARGB32()}',
                            ),
                            activeContent.icon,
                            size: activeIconSize,
                            color: activeIconColor,
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
