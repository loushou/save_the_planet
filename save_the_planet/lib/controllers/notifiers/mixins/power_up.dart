import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/collidable.dart';

abstract class PowerUp extends ChangeNotifier with Collidable {
  Offset get position;
  double get radiusSize;

  double get fireRatePercent;
  double get hpPercent;
  double get damagePercent;
  double get healPercent;

  double get fireRateValue;
  double get hpValue;
  double get damageValue;
  double get healValue;

  bool get canCollide => true;
}
