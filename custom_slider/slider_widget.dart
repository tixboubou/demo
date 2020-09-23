import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:demo/pages/home/widgets/widgets.dart';
import 'custom_slider_thumb.dart';
import 'dart:ui' as ui;

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final double sliderWidth;
  final double min;
  final double max;
  final fullWidth;
  final IconData icon;
  final String thumbImage;
  final Color iconColor;
  final LinearGradient thumbGradient;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Function(double, String) onChange;
  final String code;
  final double value;
  final double fontSizeIcon;
  final Size inputSize;

  SliderWidget({
    @required this.sliderHeight,
    @required this.sliderWidth,
    @required this.max,
    this.min = 0,
    this.fullWidth = false,
    @required this.icon,
    @required this.thumbImage,
    @required this.iconColor,
    @required this.thumbGradient,
    @required this.activeTrackColor,
    @required this.inactiveTrackColor,
    @required this.onChange,
    @required this.code,
    @required this.value,
    @required this.fontSizeIcon,
    this.inputSize,
  });

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0;
  int thumbImageHeight;
  int thumbImageWidth;
  Size _inputSize;

  final double _selectedPathBarWidth = 5;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    if (widget.inputSize != null) {
      // Size is provided, use that value
      _inputSize = widget.inputSize;
    } else {
      // Size is not provided, use default value
      _inputSize = Size(512.0, 512.0);
    }
  }

  Future<ui.Image> loadImage({@required String thumbImage}) async {
    ByteData data = await rootBundle.load(thumbImage);
    if (data == null) {
      print("data is null");
      return null;
    } else {
      var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      var frame = await codec.getNextFrame();
      /*setState(() {
        thumbImageHeight = frame.image.height;
        thumbImageWidth = frame.image.width;
        inputSize = Size(
          thumbImageWidth.toDouble(),
          thumbImageHeight.toDouble(),
        );
      });*/
      return frame.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    double thumbRadius = widget.sliderHeight * 0.4;
    //int _currentValue = (widget.max * _value).round();
    int _currentValue = _value.round();
    // width of first gap
    double firstGap = thumbRadius * 0.9;
    // width of last gap
    double lastGap = thumbRadius * 1.2;
    // width of slider
    double finalWidth =
        widget.sliderWidth - firstGap - lastGap - widget.sliderHeight;

    return Row(
      children: <Widget>[
        SizedBox(
          width: firstGap,
        ),
        Container(
          width: finalWidth,
          height: widget.sliderHeight,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: FutureBuilder<ui.Image>(
                      future: loadImage(thumbImage: widget.thumbImage),
                      builder: (BuildContext context,
                          AsyncSnapshot<ui.Image> snapshot) {
                        return SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: widget.activeTrackColor,
                            inactiveTrackColor: widget.inactiveTrackColor,
                            trackShape: CustomTrackShape(
                              currentPosition: _value,
                              max: widget.max.toDouble(),
                              min: widget.min.toDouble(),
                              selectedPathBarWidth: _selectedPathBarWidth,
                              thumbHeight: widget.sliderHeight,
                            ),
                            trackHeight: widget.sliderHeight,
                            thumbShape: CustomSliderThumb(
                              inputSize: _inputSize,
                              thumbIcon: snapshot.data,
                              thumbWidth: widget.sliderHeight,
                              thumbHeight: widget.sliderHeight,
                              thumbRadius: thumbRadius * 0.4,
                              icon: widget.icon,
                              iconColor: widget.iconColor,
                              min: widget.min,
                              max: widget.max,
                              gradient: widget.thumbGradient,
                              fontSizeIcon: widget.fontSizeIcon,
                            ),
                            overlayColor: Colors.white.withOpacity(0.1),
                          ),
                          child: Slider(
                            value: _value,
                            min: widget.min,
                            max: widget.max,
                            onChangeEnd: (value) {
                              widget.onChange(value, widget.code);
                            },
                            onChanged: (value) {
                              setState(() {
                                _value = value;
                              });
                            },
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: lastGap,
        ),
        Container(
          width: widget.sliderHeight,
          height: widget.sliderHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(widget.sliderHeight * 0.3),
            ),
            color: widget.inactiveTrackColor,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                '$_currentValue',
                style: TextStyle(
                  fontSize: thumbRadius * 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
