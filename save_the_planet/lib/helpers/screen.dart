import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:savetheplanet/helpers/math.dart';

final List<Star> _stars = <Star>[];

class Star {
  const Star({
    this.position,
    this.size,
    this.brightness,
  });

  factory Star.random(Size size) => Star(
        position: Offset(randomDouble(0, size.width), randomDouble(0, size.height)),
        size: randomDouble(0, 2),
        brightness: randomInt(0x44, 0xff),
      );

  final Offset position;
  final double size;
  final int brightness;
}

void generateStars(Size screenSize, {int count}) {
  if (_stars.isNotEmpty) {
    return;
  }
  count ??= randomInt(600, 800);
  int i;
  for (i = 0; i < count; i += 1) {
    _stars.add(Star.random(screenSize));
  }
}

Widget wrapScreen({
  Widget child,
  bool safeArea = false,
  Widget overrideBackdrop,
  Color overrideBackdropBGColor,
}) {
  Widget output = Scaffold(
    body: child,
    backgroundColor: Colors.transparent,
  );

  if (safeArea) {
    output = SafeArea(
      child: output,
    );
  }

  Widget background;
  if (overrideBackdrop != null) {
    background = overrideBackdrop;
  } else {
    background = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: CustomPaint(
          painter: StarField(
            bgColor: overrideBackdropBGColor,
          ),
        ),
      ),
    );
  }

  return Stack(
    children: <Widget>[
      background,
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: output,
      ),
    ],
  );
}

final Paint _fgColor = Paint()..color = Colors.white;

class StarField extends CustomPainter {
  StarField({
    this.bgColor = Colors.black,
  });

  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()..color = bgColor ?? Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    _stars.forEach((Star star) {
      canvas.drawRect(
        Rect.fromLTWH(star.position.dx, star.position.dy, star.size, star.size),
        _fgColor..color = Color.fromARGB(star.brightness, 255, 255, 255),
      );
    });
  }

  @override
  bool shouldRepaint(StarField oldDelegate) => bgColor != oldDelegate.bgColor;
}
