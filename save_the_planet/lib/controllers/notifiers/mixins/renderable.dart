import 'package:flutter/material.dart';

abstract class Renderable {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory Renderable._() => null;

  Offset get position;
  double get radiusSize;

  Widget render() => Container(
        height: radiusSize * 2,
        width: radiusSize * 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radiusSize),
        ),
      );
}
