import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomSliderThumb extends SliderComponentShape {
  final double min;
  final double max;
  final double thumbHeight;
  final double thumbWidth;
  final double thumbRadius;
  final Color color;
  final Gradient gradient;
  final IconData icon;
  final double fontSizeIcon;
  final Color iconColor;
  final ui.Image thumbIcon;
  final Size inputSize;

  const CustomSliderThumb({
    this.min = 0,
    this.max = 10,
    @required this.thumbRadius,
    @required this.thumbHeight,
    @required this.thumbWidth,
    @required this.icon,
    @required this.iconColor,
    this.fontSizeIcon = 25.0,
    this.color,
    this.gradient,
    @required this.thumbIcon,
    @required this.inputSize,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;

    Rect rect = Rect.fromLTWH(
      center.dx - (thumbWidth / 2),
      center.dy - (thumbHeight / 2),
      thumbWidth,
      thumbHeight,
    );

    // text icon
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontFamily: icon.fontFamily,
        fontSize: fontSizeIcon,
      ),
    );
    builder.pushStyle(
      ui.TextStyle(
        color: iconColor,
      ),
    );
    builder.addText(
      String.fromCharCode(
        icon.codePoint,
      ),
    );
    var iconString = builder.build();
    iconString.layout(
      const ui.ParagraphConstraints(
        width: 60,
      ),
    );
    // end of text icon

    final paint = Paint();
    if (color != null) {
      // we have color, thus we would use it
      paint.color = color;
      paint.style = PaintingStyle.fill;
    } else {
      // we don't have any color, thus use gradient
      paint.shader = gradient.createShader(rect);
    }

    Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - (thumbWidth / 2),
          center.dy - (thumbHeight / 2),
          thumbWidth,
          thumbHeight,
        ),
        Radius.circular(8),
      ),
    );

    // image icon
    ui.Rect inputRect;
    ui.Rect outputRect;
    Size imageSize;
    FittedSizes sizes;
    BoxFit boxFit = BoxFit.cover;

    // size of original image
    imageSize = Size(
      inputSize.width,
      inputSize.height,
    );

    sizes = applyBoxFit(
      boxFit,
      imageSize,
      Size(
        fontSizeIcon,
        fontSizeIcon,
      ),
    );
    inputRect = Alignment.center.inscribe(
      sizes.source,
      Offset.zero & imageSize,
    );
    outputRect = Alignment.center.inscribe(
      sizes.destination,
      rect,
    );
    // end of image icon

    canvas.drawPath(path, paint);


    /*canvas.drawParagraph(
      iconString,
      Offset(
        center.dx - (fontSizeIcon / 2),
        center.dy - (fontSizeIcon / 2),
      ),
    );*/

    // change color of image
    // paint.colorFilter = ColorFilter.mode(color, BlendMode.srcATop);

    canvas.drawImageRect(
      thumbIcon,
      inputRect,
      outputRect,
      paint,
    );
  }

  String getValue(double value) {
    return ((max * value).round()).toString();
  }
}