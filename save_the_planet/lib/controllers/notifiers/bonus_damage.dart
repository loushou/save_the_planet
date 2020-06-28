import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/power_up.dart';

class BonusDamage extends PowerUp {
  BonusDamage({
    double percent = 1,
    double value = 0,
    this.position,
    this.radiusSize = 10,
  })  : _damagePercent = percent,
        _damageValue = value;

  final Offset position;
  final double radiusSize;

  double _fireRatePercent = 1;
  double _hpPercent = 1;
  double _damagePercent = 1;
  double _healPercent = 1;
  double _fireRateValue = 0;
  double _hpValue = 0;
  double _damageValue = 0;
  double _healValue = 0;

  double get fireRatePercent => _fireRatePercent;
  double get hpPercent => _hpPercent;
  double get damagePercent => _damagePercent;
  double get healPercent => _healPercent;
  double get fireRateValue => _fireRateValue;
  double get hpValue => _hpValue;
  double get damageValue => _damageValue;
  double get healValue => _healValue;

  @override
  String toString() => 'BonusDamage: $_damagePercent / $_damageValue';
}
