import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const Duration _kProgressDuration = Duration(milliseconds: 225);

class _PathRippleFactory extends InteractiveInkFeatureFactory {
  const _PathRippleFactory(
    this.path, {
    this.paint,
    this.clip = false,
  })  : assert(path != null),
        assert(clip != null);

  final Path path;
  final Paint paint;
  final bool clip;

  @override
  InteractiveInkFeature create({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required Offset position,
    @required Color color,
    @required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    VoidCallback onRemoved,
  }) {
    return PathSplash(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      onRemoved: onRemoved,
      textDirection: textDirection,
      path: path,
      customPaint: paint,
      clip: clip,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
    );
  }
}

class PathSplash extends InteractiveInkFeature {
  PathSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required Offset position,
    @required Color color,
    @required TextDirection textDirection,
    VoidCallback onRemoved,
    this.path,
    Paint customPaint,
    this.clip,
    bool containedInkWell = false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
  })  : assert(color != null),
        assert(position != null),
        assert(textDirection != null),
        _textDirection = textDirection,
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _customBorder = customBorder,
        _clipCallback =
            _getClipCallback(referenceBox, containedInkWell, rectCallback),
        _radius = radius,
        super(
          controller: controller,
          referenceBox: referenceBox,
          color: color,
          onRemoved: onRemoved,
        ) {
    _progressController = AnimationController(
      duration: _kProgressDuration,
      vsync: controller.vsync,
    )
      ..addListener(controller.markNeedsPaint)
      ..forward();

    _progressAnimation = _progressController.drive(Tween<double>(
      begin: 0,
      end: 1,
    ));

    if (customPaint == null) {
      paint = Paint()
        ..color = color
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
    } else {
      paint = customPaint;
    }

    controller.addInkFeature(this);
  }

  static InteractiveInkFeatureFactory splashFactory(
    Path path, {
    Paint paint,
    bool clip = false,
  }) {
    assert(path != null);
    assert(clip != null);
    return _PathRippleFactory(path, paint: paint, clip: clip);
  }

  Animation<double> _progressAnimation;

  AnimationController _progressController;

  Paint paint;
  Path path;
  bool clip;
  final BorderRadius _borderRadius;
  final ShapeBorder _customBorder;
  final RectCallback _clipCallback;
  final TextDirection _textDirection;
  final double _radius;

  @override
  void confirm() => _progressController.reverse();

  @override
  void cancel() => _progressController.reverse();

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final progress = _progressAnimation.value;
    if (progress == 0) {
      return;
    }

    final path = this.path;
    var animatedPath = createAnimatedPath(path, progress);

    final originOffset = MatrixUtils.getAsTranslation(transform);
    final moveToCenterOfCanvasOffset = moveToCenterOfCanvas(
      referenceBox.size.center(originOffset),
      path.getBounds().center.translate(originOffset.dx, originOffset.dy),
    );

    animatedPath =
        animatedPath.shift(originOffset + moveToCenterOfCanvasOffset);

    if (!clip) {
      canvas.drawPath(animatedPath, paint);
    } else {
      drawClipped(
        canvas,
        originOffset,
        animatedPath,
        _clipCallback,
        _customBorder,
        _borderRadius,
        _textDirection,
      );
    }
  }

  void drawClipped(
    Canvas canvas,
    Offset originOffset,
    Path path,
    RectCallback clipCallback,
    ShapeBorder customBorder,
    BorderRadius borderRadius,
    TextDirection textDirection,
  ) {
    canvas.save();
    final rect = referenceBox.paintBounds.translate(
      originOffset.dx,
      originOffset.dy,
    );
    if (customBorder != null) {
      canvas.clipPath(customBorder.getOuterPath(
        rect,
        textDirection: textDirection,
      ));
    } else if (_radius != null) {
      canvas.clipRRect(RRect.fromRectXY(rect, _radius, _radius));
    } else {
      canvas.clipRect(rect);
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Offset moveToCenterOfCanvas(Offset canvasCenter, Offset pathCenter) {
    final offset = (canvasCenter - pathCenter) / 2;
    return offset;
  }

  // See https://stackoverflow.com/questions/50978603/how-to-animate-a-path-in-flutter
  Path createAnimatedPath(
    Path originalPath,
    double animationPercent,
  ) {
    // ComputeMetrics can only be iterated once!
    final totalLength = originalPath
        .computeMetrics()
        // ignore: prefer_int_literals
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    final currentLength = totalLength * animationPercent;

    return extractPathUntilLength(originalPath, currentLength);
  }

  // See https://stackoverflow.com/questions/50978603/how-to-animate-a-path-in-flutter
  Path extractPathUntilLength(
    Path originalPath,
    double length,
  ) {
    var currentLength = 0.0;

    final path = Path();

    final metricsIterator = originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      final metric = metricsIterator.current;

      final nextLength = currentLength + metric.length;

      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0, remainingLength);

        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        // There might be a more efficient way of extracting an entire path
        final pathSegment = metric.extractPath(0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }

    return path;
  }
}

RectCallback _getClipCallback(
  RenderBox referenceBox,
  bool containedInkWell,
  RectCallback rectCallback,
) {
  if (rectCallback != null) {
    assert(containedInkWell);
    return rectCallback;
  }
  if (containedInkWell) {
    return () => Offset.zero & referenceBox.size;
  }
  return null;
}
