import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/projectile.dart';
import 'package:savetheplanet/helpers/math.dart';

class BulletSmall extends Projectile {
  BulletSmall({
    this.baseDamage,
    this.baseSpeed,
    this.origin,
    this.radians,
    this.startTime,
    this.radiusSize = 1,
  }) : _position = origin;

  final double radiusSize;
  final double baseDamage;
  final double baseSpeed;
  final Offset origin;
  final double radians;
  final Duration startTime;

  bool _isActive = true;
  Offset _position;
  bool _wasDisposed = false;
  Widget _widget;

  bool get isActive => _isActive;
  Offset get position => _position;
  bool get canCollide => isActive;

  @override
  void collide() {
    _isActive = false;
    _notifyListeners();
  }

  @override
  void onTick(Duration elapsed) {
    final double distance = (elapsed.inMilliseconds - startTime.inMilliseconds).abs() * baseSpeed;
    _position = pointFromOriginAtAngleAndDistance(origin, radians, distance);
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_wasDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _wasDisposed = true;
    super.dispose();
  }
}
