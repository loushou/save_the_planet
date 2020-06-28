import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/collidable.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/has_health.dart';

class Planet extends ChangeNotifier with HasHealth, Collidable {
  Planet({
    this.origin,
    this.startTime,
    this.radiusSize = 1,
    double hp,
  })  : _position = origin,
        _hp = hp,
        _maxHp = hp;

  final double radiusSize;
  final Offset origin;
  final Duration startTime;

  bool _isActive = true;
  Offset _position;
  double _hp;
  double _lastHpChange = 0;
  double _maxHp;
  bool _wasDisposed = false;

  bool get isActive => _isActive;
  Offset get position => _position;
  bool get canCollide => isActive;
  @override
  double get hp => _hp;
  double get lastHpChange => _lastHpChange;
  @override
  double get maxHp => _maxHp;

  set hp(double value) {
    if (value != _hp) {
      _lastHpChange = value - _hp;
      _hp = value;
      _notifyListeners();
    }
  }

  @override
  void collide() {
    _isActive = false;
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
