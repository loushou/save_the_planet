import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/collidable.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/tickable.dart';

abstract class Projectile extends ChangeNotifier with Tickable, Collidable {
  double get baseDamage;

  Offset get position;

  double get radiusSize;

  bool isProjectile = true;

  void collide();

  bool isInView(Size screenSize) {
    if (position.dx + radiusSize < -screenSize.width || position.dy + radiusSize < -screenSize.height) {
      return false;
    }

    if (position.dx - radiusSize > screenSize.width * 2 || position.dy - radiusSize > screenSize.height * 2) {
      return false;
    }

    return true;
  }
}
