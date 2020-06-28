import 'dart:async';

import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/collidable.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/has_health.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/tickable.dart';
import 'package:savetheplanet/helpers/math.dart';

enum AttackerState {
  stationary,
  flying,
  dieing,
  dead,
}

class Attacker extends ChangeNotifier with Collidable, Tickable, HasHealth {
  Attacker({
    this.id,
    double hp = 10,
    double speed = 0.0015,
    double damage = 1,
    Offset startPosition = Offset.zero,
    Offset endPosition = Offset.zero,
    double radiusSize = 10,
    Duration deathDuration = const Duration(milliseconds: 300),
  })  : _hp = hp,
        _maxHp = hp,
        _speed = speed,
        _damage = damage,
        _position = startPosition,
        _startPosition = startPosition,
        _endPosition = endPosition,
        _radiusSize = radiusSize,
        _deathDuration = deathDuration {
    final int rng = randomInt(0, 9);
    _spin = rng >= 5 ? -1 : 1;
  }

  final int id;

  /// current hit points for this attacker
  double _hp;

  /// maximum hp, representing full health
  double _maxHp;

  /// pixels per MS traveled by attacker
  double _speed;

  /// the amount of damage an attacker can do to the planet
  double _damage;

  /// where the attacker started. used for trajectory
  Offset _startPosition;

  /// where the attacker will end. used for trajectory
  Offset _endPosition;

  /// the current position of the attacker
  Offset _position;

  /// the radius from the center of the attacker
  double _radiusSize;

  /// length of time the attacker stays 'dieing'
  Duration _deathDuration;

  /// on what game tick did the attacker start to move?
  int _startMS = 0;

  /// on what game tick are they expected to succeed if not killed
  int _endMS = 0;

  /// did they succeed?
  bool _succeeded = false;

  /// current state of the attacker
  AttackerState _state = AttackerState.stationary;

  /// track whether was disposed. helps prevent calling listeners on dead objects
  bool _wasDisposed = false;

  /// the spin of the attacker
  double _spin = 1;

  double get hp => _hp;
  double get maxHp => _maxHp;

  double get speed => _speed;

  double get damage => _damage;

  Offset get position => _position;

  double get radiusSize => _radiusSize;

  bool get succeeded => _succeeded;

  AttackerState get state => _state;

  bool get living => _state != AttackerState.dead && _state != AttackerState.dieing;

  bool get canCollide => living;

  Duration get deathDuration => _deathDuration;

  double get spin => _spin;

  set hp(double value) {
    if (_hp != value) {
      _hp = value;
      _notifyListeners();
    }
  }

  void start(Duration elapsed) {
    _startMS = elapsed.inMilliseconds;
    _endMS = elapsed.inMilliseconds + (distanceFormula(_startPosition, _endPosition) ~/ speed);
  }

  @override
  void onTick(Duration elapsed) {
    // stop moving once collided
    if (!canCollide) {
      return;
    }

    final int tick = elapsed.inMilliseconds;
    // do not move if we should not have started yet
    if (tick < _startMS) {
      return;
    }

    // if we should be moving right now, calculate the position
    if (tick < _endMS) {
      final double percent = _startMS != _endMS ? (tick - _startMS) / (_endMS - _startMS) : 0;
      _position = positionOnLine(_startPosition, _endPosition, percent);
      return;
    }

    // if we are past the end of the path, then we absolutely collided
    if (!_succeeded) {
      _hp = 0;
      _succeeded = true;
      _notifyListeners();
    }
  }

  void collide({bool success = false}) {
    _succeeded = success;
    hp = 0;
    _notifyListeners();
  }

  void kill() {
    collide(success: false);
  }

  void maybeStartDieing() {
    if (hp > 0) {
      return;
    }

    _state = AttackerState.dieing;
    _notifyListeners();

    Timer(_deathDuration, () {
      _state = AttackerState.dead;
      _notifyListeners();
    });
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
