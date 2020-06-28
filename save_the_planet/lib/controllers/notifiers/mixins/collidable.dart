import 'package:flutter/material.dart';
import 'package:savetheplanet/helpers/math.dart';

typedef CollideCallback = void Function(Collidable, Collidable);

abstract class Collidable {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory Collidable._() => null;

  Offset get position;
  double get radiusSize;
  bool get canCollide;

  bool checkCollision({Collidable other, Offset targetCenter, double targetRadius}) {
    final Offset testCenter = other != null ? other.position : targetCenter;
    final double testRadius = other != null ? other.radiusSize : targetRadius;

    if (testCenter == null || testRadius == null) {
      return false;
    }
    if (circlesTouching(position, radiusSize, testCenter, testRadius)) {
      return true;
    }

    return false;
  }
}
