import 'dart:math';
import 'package:flutter/material.dart';

Random _rng = Random.secure();

double distanceFormula(Offset p1, Offset p2) => sqrt(pow(p1.dx - p2.dx, 2) + pow(p1.dy - p2.dy, 2));

double radiansFromPoints(Offset p1, Offset p2) => atan2(p2.dy - p1.dy, p2.dx - p1.dx);

double radiansFromDelta(Offset p) => atan2(p.dy, p.dx);

Offset positionOnLine(Offset from, Offset to, double percent) => Offset(
      from.dx + ((to.dx - from.dx) * percent),
      from.dy + ((to.dy - from.dy) * percent),
    );

Offset pointFromOriginAtAngleAndDistance(Offset origin, double radians, double distance) => Offset(
      origin.dx + (distance * cos(radians)),
      origin.dy + (distance * sin(radians)),
    );

Offset pointFromCenterAndRadians(Offset center, double radians, {double radius = 200}) => Offset(
      center.dx + (radius * cos(radians)),
      center.dy + (radius * sin(radians)),
    );

bool circlesTouching(Offset origin1, double radius1, Offset origin2, double radius2) => distanceFormula(origin1, origin2) < radius1 + radius2;

double randomDouble(double from, double to) {
  final double percent = _rng.nextDouble();
  return from + ((to - from) * percent);
}

int randomInt(int from, int to) => _rng.nextInt(to - from + 1) + from;

Duration addDurations(Duration original, Duration adding) => Duration(
      milliseconds: (adding == null ? 0 : adding.inMilliseconds) + (original == null ? 0 : original.inMilliseconds),
    );

Size maxSize(Size s1, Size s2) => Size(max<double>(s1.width, s2.width), max<double>(s1.height, s2.height));
