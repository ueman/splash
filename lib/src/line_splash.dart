import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const Duration _kProgressDuration = Duration(milliseconds: 225);
const Duration _kFasterProgressDuration = Duration(milliseconds: 150);

class LineSplashFactory extends InteractiveInkFeatureFactory {
  const LineSplashFactory([this.paint]);

  final Paint paint;

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
    return _LineSplash(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      onRemoved: onRemoved,
      textDirection: textDirection,
      paint: paint,
    );
  }
}

class _LineSplash extends InteractiveInkFeature {
  _LineSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required Offset position,
    @required Color color,
    @required TextDirection textDirection,
    VoidCallback onRemoved,
    Paint paint,
  })  : assert(color != null),
        assert(position != null),
        assert(textDirection != null),
        super(
          controller: controller,
          referenceBox: referenceBox,
          color: color,
          onRemoved: onRemoved,
        ) {
    // Start animation as soon as possible
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

    // Add this InkFeature to the controller so that this gets drawn
    controller.addInkFeature(this);

    paint = paint ?? Paint()
      ..color = color
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }

  Animation<double> _progressAnimation;

  AnimationController _progressController;

  Paint paint;

  /// Wird aufgerufen, wenn der Nutzer den Button wirklich gedrueckt hat.
  /// Hier sollte die Animation verschnellert werden.
  @override
  void confirm() {
    _progressController..duration = _kFasterProgressDuration;
  }

  /// Wird aufgerufen, wenn der Nutzer den Button verlaesst und somit
  /// beispielsweise den Button-Press abbricht.
  /// Hier sollte also die Animation rueckgaengig gemacht werden.
  @override
  void cancel() {
    _progressController.reverse();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    // TODO: support ltr and rtl

    final progress = _progressAnimation.value;
    final rect = referenceBox.size;
    final Offset originOffset = MatrixUtils.getAsTranslation(transform);
    const double startX = 0;
    final startY = rect.height / 2;
    final endX = rect.width * progress;
    final endY = rect.height / 2;
    var path = Path();
    path.moveTo(startX, startY);
    path.lineTo(endX, endY);
    path.close();
    path = path.shift(originOffset);
    canvas.drawPath(path, paint);
  }
}
