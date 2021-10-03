import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:splash/splash.dart';

import 'package:splash/splash.dart' as splash;

const Duration _kUnconfirmedSplashDuration = Duration(seconds: 1);
const Duration _kSplashFadeDuration = Duration(milliseconds: 200);

const double _kSplashInitialSize = 4; // logical pixels
const double _kSplashConfirmedVelocity = 0.4; // logical pixels per millisecond

RectCallback? _getClipCallback(
    RenderBox referenceBox, bool containedInkWell, RectCallback? rectCallback) {
  if (rectCallback != null) {
    assert(containedInkWell);
    return rectCallback;
  }
  if (containedInkWell) {
    return () => Offset.zero & referenceBox.size;
  }
  return null;
}

double _getTargetRadius(
  RenderBox referenceBox,
  bool containedInkWell,
  RectCallback? rectCallback,
  Offset position,
) {
  if (containedInkWell) {
    final Size size =
        rectCallback != null ? rectCallback().size : referenceBox.size;
    return _getSplashRadiusForPositionInSize(size, position);
  }
  return Material.defaultSplashRadius;
}

double _getSplashRadiusForPositionInSize(Size bounds, Offset position) {
  final double d1 = (position - bounds.topLeft(Offset.zero)).distance;
  final double d2 = (position - bounds.topRight(Offset.zero)).distance;
  final double d3 = (position - bounds.bottomLeft(Offset.zero)).distance;
  final double d4 = (position - bounds.bottomRight(Offset.zero)).distance;
  return math.max(math.max(d1, d2), math.max(d3, d4)).ceilToDouble();
}

class _WaveSplashFactory extends InteractiveInkFeatureFactory {
  const _WaveSplashFactory(this.strokeWidth, this.blurStrength);

  final double strokeWidth;
  final double blurStrength;

  @override
  @factory
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return WaveSplash(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
      textDirection: textDirection,
    );
  }
}

/// [WaveSplash], which is an ink feature that draws a wave (like a blurred
/// circle).
///
/// See also:
///
///  * [LineSplash], which is an ink splash feature that draws a single line
///    across a button.
// ignore: deprecated_member_use_from_same_package
///  * [splash.NoSplash], which disables all ripple or splash effects.
///  * [PathSplash], which animates a drawing of a path.
///  * [WaveSplash], which is an ink feature that draws a wave (like a blurred
///    circle).
class WaveSplash extends InteractiveInkFeature {
  WaveSplash({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required TextDirection textDirection,
    required Offset position,
    required Color color,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  })  : _position = position,
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _customBorder = customBorder,
        _targetRadius = radius ??
            _getTargetRadius(
                referenceBox, containedInkWell, rectCallback, position),
        _clipCallback =
            _getClipCallback(referenceBox, containedInkWell, rectCallback),
        _repositionToReferenceBox = !containedInkWell,
        _textDirection = textDirection,
        super(
            controller: controller,
            referenceBox: referenceBox,
            color: color,
            onRemoved: onRemoved) {
    _radiusController = AnimationController(
        duration: _kUnconfirmedSplashDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
    _radius = _radiusController.drive(Tween<double>(
      begin: _kSplashInitialSize,
      end: _targetRadius,
    ));
    _alphaController = AnimationController(
        duration: _kSplashFadeDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaStatusChanged);
    _alpha = _alphaController.drive(IntTween(
      begin: color.alpha,
      end: 0,
    ));

    controller.addInkFeature(this);
  }

  final Offset _position;
  final BorderRadius _borderRadius;
  final ShapeBorder? _customBorder;
  final double _targetRadius;
  final RectCallback? _clipCallback;
  final bool _repositionToReferenceBox;
  final TextDirection _textDirection;

  late Animation<double> _radius;
  late AnimationController _radiusController;

  late Animation<int> _alpha;
  late AnimationController _alphaController;

  /// Used to specify this type of ink splash for an [InkWell], [InkResponse]
  /// or material [Theme].
  static const InteractiveInkFeatureFactory splashFactory =
      _WaveSplashFactory(30, 5);

  static InteractiveInkFeatureFactory customSplashFactory({
    double strokeWidth = 30,
    double blurStrength = 5,
  }) {
    assert(blurStrength >= 0);
    assert(strokeWidth >= 0);
    return _WaveSplashFactory(strokeWidth, blurStrength);
  }

  @override
  void confirm() {
    final int duration = (_targetRadius / _kSplashConfirmedVelocity).floor();
    _radiusController
      ..duration = Duration(milliseconds: duration)
      ..forward();
    _alphaController.forward();
  }

  @override
  void cancel() {
    _alphaController.forward();
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      dispose();
    }
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _alphaController.dispose();
    //_alphaController = null;
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withAlpha(_alpha.value)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..strokeWidth = 30;

    Offset center = _position;
    if (_repositionToReferenceBox)
      center = Offset.lerp(
        center,
        referenceBox.size.center(Offset.zero),
        _radiusController.value,
      )!;

    paintBlurredCircle(
      canvas: canvas,
      transform: transform,
      paint: paint,
      center: center,
      textDirection: _textDirection,
      radius: _radius.value,
      customBorder: _customBorder,
      borderRadius: _borderRadius,
      clipCallback: _clipCallback,
    );
  }

  void paintBlurredCircle({
    required Canvas canvas,
    required Matrix4 transform,
    required Paint paint,
    required Offset center,
    required double radius,
    required TextDirection textDirection,
    ShapeBorder? customBorder,
    BorderRadius borderRadius = BorderRadius.zero,
    RectCallback? clipCallback,
  }) {
    final Offset? originOffset = MatrixUtils.getAsTranslation(transform);
    canvas.save();
    if (originOffset == null) {
      canvas.transform(transform.storage);
    } else {
      canvas.translate(originOffset.dx, originOffset.dy);
    }
    if (clipCallback != null) {
      final Rect rect = clipCallback();
      if (customBorder != null) {
        canvas.clipPath(
            customBorder.getOuterPath(rect, textDirection: textDirection));
      } else if (borderRadius != BorderRadius.zero) {
        canvas.clipRRect(RRect.fromRectAndCorners(
          rect,
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        ));
      } else {
        canvas.clipRect(rect);
      }
    }

    final circle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(circle, paint);
    canvas.restore();
  }
}
