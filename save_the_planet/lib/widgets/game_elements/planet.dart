import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

final Paint _imagePaint = Paint();

class PlanetElement extends StatefulWidget {
  const PlanetElement({
    this.height = 100,
    this.width = 100,
  });

  final double height;
  final double width;

  @override
  _PlanetElementState createState() => _PlanetElementState();
}

class _PlanetElementState extends State<PlanetElement> with TickerProviderStateMixin {
  AnimationController _controller;
  Duration _animationDuration = const Duration(seconds: 10);
  ui.Image _image;
  double _lastImageHeight;

  @override
  Widget build(BuildContext context) {
    Offset pos = Offset.zero;
    if (_image is ui.Image) {
      final double ratio = _image.width / _image.height;
      final adjustedWidth = ratio * widget.height;
      pos = Offset(-_controller.value * adjustedWidth, 0);
    }

    return Container(
      height: widget.height + 6,
      width: widget.width + 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height),
        border: Border.all(color: Colors.white, width: 3, style: BorderStyle.solid),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height),
        child: CustomPaint(
          painter: PaintThePlanet(image: _image, offset: pos),
        ),
      ),
    );
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..addListener(_update);
  }

  void _destroyAnimation() {
    _controller.dispose();
  }

  Future<void> _loadImage() async {
    // only recalc the image if it has changed size
    if (_lastImageHeight == widget.height) {
      return;
    }
    _lastImageHeight = widget.height;

    // load the image into a byte list
    final ByteData raw = await rootBundle.load('assets/planet/bw-map.png');
    final Uint8List bytes = Uint8List.view(raw.buffer);

    // resize the image for this widget size
    final img.Image rawImage = img.decodeImage(bytes);
    final img.Image resized = img.copyResize(
      rawImage,
      height: widget.height.toInt(),
    );
    final Uint8List resizedBytes = img.encodePng(resized, level: 0);

    // create an image from the resized bytes
    ui.decodeImageFromList(resizedBytes, (ui.Image output) {
      _image = output;
    });
  }

  Future<void> _onFirstFrame(Duration _) async {
    _loadImage();
    _controller.repeat(min: 0, max: 1, reverse: false, period: _animationDuration);
  }

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    WidgetsBinding.instance.addPostFrameCallback(_onFirstFrame);
  }

  @override
  void dispose() {
    _destroyAnimation();
    super.dispose();
  }

  @override
  void didUpdateWidget(PlanetElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      _loadImage();
    }
  }
}

class PaintThePlanet extends CustomPainter {
  const PaintThePlanet({
    @required this.image,
    @required this.offset,
  });

  final ui.Image image;
  final Offset offset;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (image == null) {
      return;
    }

    // paint the image twice, end to end, to create the infinite scroll effect horizontally
    canvas.drawImage(image, offset, _imagePaint);
    canvas.drawImage(image, Offset(offset.dx + image.width, offset.dy), _imagePaint);
  }

  @override
  bool shouldRepaint(PaintThePlanet oldDelegate) {
    return image != oldDelegate.image || offset != oldDelegate.offset;
  }
}
