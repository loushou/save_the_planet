import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:savetheplanet/controllers/notifiers/heal.dart';
import 'package:savetheplanet/controllers/notifiers/attacker.dart';
import 'package:savetheplanet/controllers/notifiers/bonus_damage.dart';
import 'package:savetheplanet/controllers/notifiers/defender.dart';
import 'package:savetheplanet/controllers/notifiers/fast_fire.dart';
import 'package:savetheplanet/controllers/notifiers/max_hp.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/collidable.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/power_up.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/projectile.dart';
import 'package:savetheplanet/helpers/math.dart';
import 'package:savetheplanet/helpers/sound.dart';

import 'notifiers/planet.dart';

export 'package:savetheplanet/controllers/notifiers/defender.dart';

enum GameState {
  created,
  running,
  paused,
  ending,
  ended,
}

class ScoreNotifier extends ValueNotifier<int> {
  ScoreNotifier(int value) : super(value);
}

class LevelNotifier extends ValueNotifier<int> {
  LevelNotifier(int value) : super(value);
}

class GameStateNotifier extends ValueNotifier<GameState> {
  GameStateNotifier(GameState value) : super(value);
}

class GameController extends ChangeNotifier {
  GameController({
    Size screenSize,
    this.planetRadius = 100,
    this.planetBorder = 3,
    this.onTick,
    int startingLevel = 1,
  }) {
    this.screenSize = _screenSize;
    level.value = startingLevel;
    _ticker = Ticker(_onTick);
    _spawnNextAttacker = _attackerSpawnRateMin;
    score.addListener(_recalcLevel);
    level.addListener(_maybePromoteDefenders);
  }

  final _baseLevelScore = 10;
  Planet _planet;
  Size _screenSize;
  Offset _center;
  Ticker _ticker;
  Duration _adjustTicks;
  Duration _lastElapsed;
  int _spawnNextAttacker;
  int _attackerSpawnRateMin = 500;
  int _attackerSpawnRateMax = 2500;
  final VoidCallback onTick;
  final double planetRadius;
  final double planetBorder;

  final ScoreNotifier score = ScoreNotifier(0);
  final LevelNotifier level = LevelNotifier(1);
  final GameStateNotifier state = GameStateNotifier(GameState.created);

  final List<Defender> _defenders = <Defender>[];
  final List<Attacker> _attackers = <Attacker>[];
  final List<Projectile> _projectiles = <Projectile>[];
  final List<PowerUp> _powerups = <PowerUp>[];

  Planet get planet => _planet;

  List<Defender> get defenders => List<Defender>.unmodifiable(_defenders);

  List<Attacker> get attackers => List<Attacker>.unmodifiable(_attackers);

  List<Projectile> get projectiles => List<Projectile>.unmodifiable(_projectiles);

  List<PowerUp> get powerups => List<PowerUp>.unmodifiable(_powerups);

  Ticker get ticker => _ticker;

  set screenSize(Size value) {
    if (value != null) {
      _screenSize = value;
      _center = Offset(_screenSize.width / 2, _screenSize.height / 2);
    }
  }

  void start() {
    if (state.value == GameState.created) {
      _spawnDefender();
    }
    _planet = Planet(
      origin: _center,
      startTime: const Duration(milliseconds: 0),
      radiusSize: planetRadius,
      hp: 100,
    );
    _ticker.start();
    state.value = GameState.running;
  }

  void pause() {
    _ticker.stop();
    _adjustTicks = addDurations(_adjustTicks, _lastElapsed);
    _lastElapsed = null;
    state.value = GameState.paused;
  }

  void end() {
    if (state.value == GameState.ending) {
      state.value = GameState.ended;
    }
  }

  void _maybePromoteDefenders() {
    defenders.forEach((Defender defender) {
      defender.applyPowerUp(
        FasterFire(percent: randomDouble(1.01, 1.1), value: randomDouble(0.01, (level.value.toDouble() / 20))),
      );
      defender.applyPowerUp(
        BonusDamage(percent: randomDouble(1.3, 1.5), value: randomDouble(1, level.value.toDouble())),
      );
      defender.applyPowerUp(
        MaxHp(percent: randomDouble(1.25, 1.75), value: randomDouble(1, level.value.toDouble())),
      );
      defender.applyPowerUp(
        HealHp(percent: 1, value: 0),
      );
    });
  }

  void _recalcLevel() {
    final double targetScoreNextLevel = pow(2.3, level.value) * _baseLevelScore;
    if (score.value >= targetScoreNextLevel) {
      level.value += 1;
      _recalcLevel();
    }
  }

  void _onTick(Duration elapsed) {
    _lastElapsed = elapsed;
    final Duration fullElapsed = addDurations(_adjustTicks, elapsed);

    _updateProjectiles(fullElapsed);
    _cleanProjectiles(fullElapsed);
    _updateDefenders(fullElapsed);
    _updateAttackers(fullElapsed);
    _spawnAttackers(fullElapsed);
    _checkCollisions(fullElapsed);
    _verifyDefendersPresent(fullElapsed);
    _verifyPlanetAlive(fullElapsed);

    if (onTick != null) {
      onTick();
    }
  }

  // make sure that the planet still has some health
  void _verifyPlanetAlive(Duration elapsed) {
    if (_planet.hp <= 0) {
      pause();
      state.value = GameState.ending;
      stpAudioCache.fixedPlayer.stop();
      stpAudioCache.play('sounds/failure.mp3', volume: 0.25);
    }
  }

  // make sure that there is at least one defender present. if not, end game
  void _verifyDefendersPresent(Duration elapsed) {
    final List<Defender> livingDefenders = defenders.where((Defender defender) => defender.state != DefenderState.created && defender.state != DefenderState.dead).toList();
    if (livingDefenders.isEmpty) {
      pause();
      state.value = GameState.ending;
      stpAudioCache.fixedPlayer.stop();
      stpAudioCache.play('sounds/failure.mp3', volume: 0.25);
    }
  }

  // check for collisions between attackers and defenders
  void _checkCollisions(Duration elapsed) {
    _checkCollidables(defenders, powerups, (Collidable def, Collidable pwu) {
      final Defender defender = def;
      final PowerUp powerup = pwu;
      defender.applyPowerUp(powerup);
      _powerups.remove(powerup);
      stpPwrAudioCache.fixedPlayer.stop();
      stpPwrAudioCache.play('sounds/powerup.mp3', volume: 0.15);
    });
    _checkCollidables(defenders, attackers, (Collidable def, Collidable att) {
      final Defender defender = def;
      final Attacker attacker = att;
      defender.hp -= attacker.hp / 2;
      attacker.kill();
    });
    _checkCollidables(projectiles, attackers, (Collidable prj, Collidable att) {
      final Projectile projectile = prj;
      final Attacker attacker = att;
      attacker.hp -= projectile.baseDamage;
      projectile.collide();
      _removeProjectile(projectile);
    });
    _checkCollidables(projectiles, <Collidable>[_planet], (Collidable prj, Collidable plt) {
      final Projectile projectile = prj;
      final Planet planet = plt;
      planet.hp -= projectile.baseDamage;
      projectile.collide();
      _removeProjectile(projectile);
    });
  }

  // check collisions between two collidable groups
  void _checkCollidables(List<Collidable> group1, List<Collidable> group2, CollideCallback onCollide) {
    if (onCollide == null) {
      return;
    }

    int i;
    int j;
    for (i = 0; i < group1.length; i += 1) {
      for (j = 0; j < group2.length; j += 1) {
        if (group1[i].canCollide && group2[j].canCollide && group1[i].checkCollision(other: group2[j])) {
          onCollide(group1[i], group2[j]);
        }
      }
    }
  }

  // update the position of each attacker based on the time elapsed.
  // if they hit the planet, start the death sequence
  void _updateAttackers(Duration elapsed) {
    int i;
    for (i = 0; i < attackers.length; i += 1) {
      attackers[i].onTick(elapsed);
      // if they hit the planet
      if (attackers[i].canCollide && attackers[i].checkCollision(targetRadius: _planet.radiusSize + 3, targetCenter: _planet.origin)) {
        attackers[i].collide(success: true);
      }
    }
  }

  // tell each defender of the new tick. they may have actions to take
  void _updateDefenders(Duration elapsed) {
    int i;
    for (i = 0; i < defenders.length; i += 1) {
      defenders[i].onTick(elapsed);
    }
  }

  // tell each projectile of the new tick. they may have actions to take
  void _updateProjectiles(Duration elapsed) {
    int i;
    for (i = 0; i < projectiles.length; i += 1) {
      projectiles[i].onTick(elapsed);
    }
  }

  // cleanup the projectiles. remove the ones no longer in view
  void _cleanProjectiles(Duration elapsed) {
    int i;
    for (i = 0; i < projectiles.length; i += 1) {
      if (!projectiles[i].isInView(_screenSize)) {
        _removeProjectile(projectiles[i]);
      }
    }
  }

  // create new attackers, if allowed and if the time requirements have been met
  void _spawnAttackers(Duration elapsed) {
    if (attackers.length < (level.value * 7) && elapsed.inMilliseconds > _spawnNextAttacker) {
      _calcNextSpawn(elapsed);
      _spawnAttacker(elapsed);
    }
  }

  // update the timer for the next spawn
  void _calcNextSpawn(Duration elapsed) {
    _spawnNextAttacker = elapsed.inMilliseconds + (randomInt(_attackerSpawnRateMin, _attackerSpawnRateMax) * (1 - (sqrt(level.value) / 100))).toInt();
  }

  void _maybeDrop(Attacker attacker) {
    final Offset dropLocation = attacker.position;
    final double dropRoll = randomDouble(0, 100);
    if (dropRoll < 23.79) {
      PowerUp powerup;
      final int giftType = randomInt(0, 3);
      final int giftMode = randomInt(0, 3);
      switch (giftType) {
        case 0:
          final double prc = giftMode < 3 ? randomDouble(1.03, 1.1) : 1;
          final double md = giftMode == 3 ? randomDouble(0.01, 0.03) : 0;
          powerup = FasterFire(
            percent: prc,
            value: md,
            position: dropLocation,
          );
          print('%%%% FASTER FIRE: $prc // $md /// $powerup');
          break;
        case 1:
          powerup = MaxHp(
            percent: giftMode < 3 ? randomDouble(1.1, 1.3) : 1,
            value: giftMode == 3 ? randomDouble(10, 30) : 0,
            position: dropLocation,
          );
          break;
        case 2:
          powerup = BonusDamage(
            percent: giftMode < 3 ? randomDouble(1.1, 1.25) : 1,
            value: giftMode == 3 ? randomDouble(5, 20) : 0,
            position: dropLocation,
          );
          break;
        case 3:
          powerup = HealHp(
            percent: giftMode < 3 ? randomDouble(0.5, 0.75) : 1,
            value: giftMode == 3 ? randomDouble(20, 50) : 0,
            position: dropLocation,
          );
          break;

        default:
          break;
      }

      if (powerup != null) {
        _powerups.add(powerup);
      }
    }
  }

  VoidCallback _onAttackerChange(Attacker attacker) {
    VoidCallback listener;
    listener = () {
      // if they have 0 hp and have not started dieing yet, do so now
      if (attacker.state != AttackerState.dead && attacker.state != AttackerState.dieing && attacker.hp <= 0) {
        attacker.maybeStartDieing();

        // if it succeeded, then deduct the damage from the planet
        if (attacker.succeeded) {
          stpExpAudioCache.fixedPlayer.stop();
          stpExpAudioCache.play('sounds/explosion.mp3', volume: 0.15);
          planet.hp -= attacker.damage;
        } else {
          stpSaveAudioCache.fixedPlayer.stop();
          stpSaveAudioCache.play('sounds/saved.mp3', volume: 0.05);
        }
      }

      // if the thing is dead, remove it from the list, remove the listener, and destroy it
      if (attacker.state == AttackerState.dead) {
        // increment the score if the defender killed the attacker before it hit the planet
        if (!attacker.succeeded) {
          score.value += level.value;
          _maybeDrop(attacker);
        }

        // remove it from the list of attackers and also remove the listener that handles this logic
        _attackers.remove(attacker);
        attacker.removeListener(listener);
      }
    };

    return listener;
  }

  VoidCallback _onDefenderChange(Defender defender) {
    VoidCallback listener;
    listener = () {
      if (defender.state != DefenderState.dead && defender.state != DefenderState.dieing) {
        if (defender.hp <= 0) {
          defender.maybeStartDieing();
          return;
        } else if (circlesTouching(_center, planetRadius, defender.position, defender.radiusSize)) {
          defender.kill();
          defender.maybeStartDieing();
          return;
        }
      }

      if (defender.state == DefenderState.dead) {
        _defenders.remove(defender);
        defender.removeListener(listener);
      }
    };

    return listener;
  }

  int cnt = 0;

  // create a single attacker
  void _spawnAttacker(Duration elapsed) {
    // build the attacker
    final Attacker attacker = Attacker(
      id: cnt++,
      hp: 1 + (9 * level.value).toDouble(),
      speed: 0.03 + (0.01 * level.value),
      startPosition: _randomStartPos(),
      endPosition: _randomEndPos(),
      radiusSize: 15,
    );

    // add the death listener
    attacker.addListener(_onAttackerChange(attacker));

    // start it's approach
    attacker.start(elapsed);

    // add it to the list
    _attackers.add(attacker);
  }

  void _spawnDefender() {
    final Defender defender = Defender(
      addBulletCallback: _addProjectile,
      hp: 10,
      rotation: -(pi / 2),
      fireRate: 1,
      baseDamage: 10,
      radiusSize: 15,
      position: Offset(
        _screenSize.width / 2,
        _screenSize.height * 0.35,
      ),
    );

    defender.addListener(_onDefenderChange(defender));
    defender.start(const Duration(milliseconds: 0));

    _defenders.add(defender);
  }

  void _addProjectile(Collidable projectile) {
    if (projectile == null || projectile is! Projectile) {
      return;
    }
    _projectiles.add(projectile);
    stpAudioCache.fixedPlayer.stop();
    stpAudioCache.play('sounds/fire.mp3', volume: 0.05);
  }

  void _removeProjectile(Collidable projectile) {
    if (projectile == null || projectile is! Projectile) {
      return;
    }
    _projectiles.remove(projectile);
  }

  // determine a random starting position based on the level
  Offset _randomStartPos() {
    final int rnd = randomInt(0, 1);
    if (level.value < 2 || rnd == 0) {
      return Offset(randomInt(0, _screenSize.width.ceil()).toDouble(), -20);
    }

    return Offset(_screenSize.width / 2, _screenSize.height + 20);
  }

  // determine a random ending position on the planet based on level
  Offset _randomEndPos() {
    final int rnd = randomInt(0, 1);
    if (level.value < 2 || rnd == 0) {
      final double radians = -randomDouble(0, 3.14159263);
      return pointFromCenterAndRadians(_center, radians, radius: planetRadius);
    }
    final double radians = randomDouble(0, 3.14159263);
    return pointFromCenterAndRadians(_center, radians, radius: planetRadius);
  }

  @override
  void dispose() {
    _ticker.stop(canceled: true);
    _ticker.dispose();
    super.dispose();
  }
}
