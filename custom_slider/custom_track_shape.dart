import 'package:flutter/material.dart';

class CustomTrackShape extends SliderTrackShape {
  final double max;
  final double min;
  final double selectedPathBarWidth;
  final double currentPosition;
  final double borderRadius;
  double trackWidth;
  final double thumbHeight;

  CustomTrackShape({
    @required this.max,
    @required this.min,
    @required this.currentPosition,
    this.thumbHeight = 20.0,
    this.borderRadius = 8.0,
    this.selectedPathBarWidth = 3,
  });

  @override
  Rect getPreferredRect(
      {RenderBox parentBox,
        Offset offset = Offset.zero,
        SliderThemeData sliderTheme,
        bool isEnabled,
        bool isDiscrete}) {
    final double thumbWidth = sliderTheme.thumbShape
        .getPreferredSize(
      isEnabled,
      isDiscrete,
    )
        .width;
    final double trackHeight = sliderTheme.trackHeight;
    assert(thumbWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= thumbWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackLeft = offset.dx + thumbWidth / 2;
    trackWidth = parentBox.size.width - thumbWidth;

    return Rect.fromLTWH(
      trackLeft,
      trackTop,
      trackWidth,
      trackHeight,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset,
      {RenderBox parentBox,
        SliderThemeData sliderTheme,
        Animation<double> enableAnimation,
        Offset thumbCenter,
        bool isEnabled,
        bool isDiscrete,
        TextDirection textDirection}) {
    // Check for slider track height
    if (sliderTheme.trackHeight == 0) return;
    // Get the rect that we just calculated
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Calculate the width for which the default players
    // This is the position of left and right tracks that follow thumb
    double currentTrackPosition = (currentPosition - min) * (trackWidth / (max - min));

    // calculating the paint
    // for the default path (initial width)
    final Paint defaultPathPaint = Paint()
      ..color = sliderTheme.activeTrackColor
      ..style = PaintingStyle.fill;

    // calculate the path segment for
    // the default width
    final defaultPathSegment = Path();
    defaultPathSegment.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(trackRect.left - (thumbHeight / 2), trackRect.top),
          Offset(
              trackRect.left + currentTrackPosition,
              trackRect.bottom),
        ),
        Radius.circular(borderRadius),
      ),
    );

    context.canvas.drawPath(defaultPathSegment, defaultPathPaint);

    //calculate the paint for the path segment
    // that is unselected (inactive track)
    final unselectedPathPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = sliderTheme.inactiveTrackColor;

    final unselectedPathSegment = Path();
    unselectedPathSegment.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(trackRect.right + (thumbHeight / 2), trackRect.top),
          Offset(
            trackRect.left + currentTrackPosition,
            trackRect.bottom,
          ),
        ),
        Radius.circular(borderRadius),
      ),
    );

    context.canvas.drawPath(unselectedPathSegment, unselectedPathPaint);
  }
}
