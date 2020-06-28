import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/bonus_damage.dart';
import 'package:savetheplanet/controllers/notifiers/bullet_small.dart';
import 'package:savetheplanet/controllers/notifiers/fast_fire.dart';
import 'package:savetheplanet/controllers/notifiers/heal.dart';
import 'package:savetheplanet/controllers/notifiers/max_hp.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/collidable.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/has_health.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/power_up.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/tickable.dart';
import 'package:savetheplanet/helpers/math.dart';

enum DefenderState {
  created,
  spawning,
  spawned,
  dieing,
  dead,
}

class Defender extends ChangeNotifier with Collidable, Tickable, HasHealth {
  Defender({
    double hp = 10,
    double rotation = 0,
    double fireRate = 1,
    double baseDamage = 10,
    double radiusSize = 10,
    Offset position = Offset.zero,
    Duration spawnDuration = const Duration(milliseconds: 2000),
    Duration deathDuration = const Duration(milliseconds: 500),
    @required this.addBulletCallback,
  })  : _hp = hp,
        _maxHp = hp,
        _rotation = rotation,
        _fireRate = fireRate,
        _baseDamage = baseDamage,
        _radiusSize = radiusSize,
        _position = position,
        _spawnDuration = spawnDuration,
        _deathDuration = deathDuration {
    _touchRadiusSize = max(_radiusSize, 40);
  }

  final Function(Collidable) addBulletCallback;

  bool _wasDisposed = false;
  int _startMS;
  int _nextBullet;
  double _hp;
  double _maxHp;
  double _rotation;
  double _fireRate;
  double _baseDamage;
  double _radiusSize;
  double _touchRadiusSize;
  Offset _position;
  DefenderState _state = DefenderState.created;
  Duration _spawnDuration;
  Duration _deathDuration;
  bool _moving = false;

  Widget _widget;

  @override
  double get hp => _hp;

  @override
  double get maxHp => _maxHp;

  double get rotation => _rotation;

  double get fireRate => _fireRate;

  double get baseDamage => _baseDamage;

  double get radiusSize => _radiusSize;

  Offset get position => _position;

  DefenderState get state => _state;

  bool get canCollide => hp > 0;

  bool get moving => _moving;

  set hp(double value) {
    if (_hp != value) {
      _hp = value;
      _notifyListeners();
    }
  }

  set rotation(double value) {
    if (_rotation != value) {
      _rotation = value;
      _notifyListeners();
    }
  }

  set fireRate(double value) {
    if (_fireRate != value) {
      _fireRate = value;
      _notifyListeners();
    }
  }

  set baseDamage(double value) {
    if (_baseDamage != value) {
      _baseDamage = value;
      _notifyListeners();
    }
  }

  set position(Offset value) {
    if (_position != value) {
      _position = value;
      _notifyListeners();
    }
  }

  set moving(bool value) {
    if (_moving != value) {
      _moving = value;
      _notifyListeners();
    }
  }

  void applyPowerUp(PowerUp powerup) {
    print('!!! APPLY BONUS: $powerup');
    if (powerup is FasterFire) {
      _fireRate = (_fireRate * powerup.fireRatePercent) + powerup.fireRateValue;
    } else if (powerup is MaxHp) {
      final double originalMax = _maxHp;
      _maxHp = (_maxHp * powerup.hpPercent) + powerup.hpValue;
      final double diff = _maxHp - originalMax;
      _hp = min(_maxHp, _hp + diff);
    } else if (powerup is BonusDamage) {
      _baseDamage = (_baseDamage * powerup.damagePercent) + powerup.damageValue;
    } else if (powerup is HealHp) {
      _hp = min(_maxHp, _hp + (_maxHp * powerup.damagePercent) + powerup.damageValue);
    }
    _notifyListeners();
  }

  void _updateNextBullet() {
    _nextBullet = (_nextBullet ?? _startMS) + (1000 ~/ fireRate);
  }

  void start(Duration elapsed) {
    _startMS = elapsed.inMilliseconds;
    _updateNextBullet();

    _state = DefenderState.spawning;

    Timer(_spawnDuration, () {
      _state = DefenderState.spawned;
      _notifyListeners();
    });

    _notifyListeners();
  }

  @override
  void onTick(Duration elapsed) {
    if (!canCollide) {
      return;
    }

    if (addBulletCallback == null) {
      return;
    }

    if (elapsed.inMilliseconds < _nextBullet) {
      return;
    }
    _updateNextBullet();

    addBulletCallback(
      BulletSmall(
        origin: position,
        baseDamage: baseDamage,
        baseSpeed: 0.1,
        radians: rotation,
        startTime: elapsed,
      ),
    );
  }

  void kill() {
    hp = 0;
    _notifyListeners();
  }

  void maybeStartDieing() {
    if (hp > 0) {
      return;
    }

    _state = DefenderState.dieing;
    Timer(_deathDuration, () {
      _state = DefenderState.dead;
      _notifyListeners();
    });

    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_wasDisposed) {
      notifyListeners();
    }
  }

  bool pointWithinBounds(Offset point) => distanceFormula(point, position) < _touchRadiusSize;

  @override
  void dispose() {
    _wasDisposed = true;
    super.dispose();
  }
}
