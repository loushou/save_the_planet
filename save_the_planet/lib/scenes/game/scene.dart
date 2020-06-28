import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:savetheplanet/controllers/game_controller.dart';
import 'package:savetheplanet/controllers/notifiers/attacker.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/collidable.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/power_up.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/projectile.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/renderable.dart';
import 'package:savetheplanet/helpers/screen.dart';
import 'package:savetheplanet/helpers/sound.dart';
import 'package:savetheplanet/scenes/game/actors/attacker.dart';
import 'package:savetheplanet/scenes/game/actors/defender.dart';
import 'package:savetheplanet/scenes/game/actors/planet.dart';
import 'package:savetheplanet/scenes/game/actors/powerup.dart';
import 'package:savetheplanet/scenes/game/actors/projectile.dart';
import 'package:savetheplanet/scenes/game/decorations/game_over.dart';
import 'package:savetheplanet/scenes/game/decorations/hud.dart';
import 'package:savetheplanet/scenes/game/utils/drag_detector.dart';
import 'package:savetheplanet/widgets/effects/matrix_animation.dart';
import 'package:savetheplanet/widgets/effects/random_shake.dart';
import 'package:savetheplanet/widgets/game_elements/planet.dart';

class GameScene extends StatefulWidget {
  const GameScene();

  @override
  _GameSceneState createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> with TickerProviderStateMixin {
  bool _doneAnimating = false;
  Size _screenSize;
  GameController _controller;
  double _lastPlanetHp = 0;
  AnimationController _animationController;
  AnimationController _animationControllerShake;
  Animation<Color> _colorAnimation;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      Center(
        child: _doneAnimating
            ? PlanetDisplay(
                planet: _controller.planet,
              )
            : UnidirectionalScaleAnimation(
                startScale: 1.5,
                endScale: 1,
                forwardDuration: const Duration(milliseconds: 600),
                curve: Curves.easeIn,
                child: PlanetElement(
                  height: 200,
                  width: 200,
                ),
                onComplete: () {
                  _doneAnimating = true;
                  _startGame();
                },
              ),
      ),
    ];

    children.addAll(_buildAttackers());
    children.addAll(_buildDefenders());
    children.addAll(_buildProjectiles());
    children.addAll(_buildPowerUps());
    children.addAll(_buildStateOverlays());

    final Widget stack = Stack(
      children: children,
    );

    return WillPopScope(
      onWillPop: () {
        _controller.pause();
        _controller.end();
        stpBgAudioCache.fixedPlayer.stop();
        stpBgAudioCache.loop('music/menu-music.mp3', volume: 0.1);
        return Future<bool>.value(true);
      },
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<GameController>.value(value: _controller),
          ChangeNotifierProvider<ScoreNotifier>.value(value: _controller.score),
          ChangeNotifierProvider<LevelNotifier>.value(value: _controller.level),
          ChangeNotifierProvider<GameStateNotifier>.value(value: _controller.state),
        ],
        child: GameHUD(
          child: DragDetector(
            child: RandomShake(
              child: wrapScreen(
                child: stack,
                overrideBackdropBGColor: _colorAnimation?.value ?? Colors.black,
              ),
              controller: _animationControllerShake,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDefenders() {
    if (_controller == null) {
      return <Widget>[Container()];
    }
    return _controller.defenders.map((Defender defender) {
      return Positioned(
        top: defender.position.dy,
        left: defender.position.dx,
        child: DefenderDisplay(
          defender: defender,
        ),
      );
    }).toList();
  }

  List<Widget> _buildAttackers() {
    if (_controller == null) {
      return <Widget>[Container()];
    }
    return _controller.attackers.map((Attacker attacker) {
      return Positioned(
        top: attacker.position.dy,
        left: attacker.position.dx,
        child: AttackerDisplay(
          attacker: attacker,
        ),
      );
    }).toList();
  }

  List<Widget> _buildProjectiles() {
    if (_controller == null) {
      return <Widget>[Container()];
    }
    return _controller.projectiles.map((Projectile projectile) {
      return Positioned(
        top: projectile.position.dy,
        left: projectile.position.dx,
        child: ProjectileDisplay(
          projectile: projectile,
        ),
      );
    }).toList();
  }

  List<Widget> _buildPowerUps() {
    if (_controller == null) {
      return <Widget>[Container()];
    }
    return _controller.powerups.map((PowerUp powerup) {
      return Positioned(
        top: powerup.position.dy,
        left: powerup.position.dx,
        child: PowerupDisplay(
          powerup: powerup,
        ),
      );
    }).toList();
  }

  List<Widget> _buildStateOverlays() {
    return <Widget>[
      Positioned(
        left: 0,
        right: 0,
        top: (_screenSize?.height ?? 0) * 0.35,
        child: const GameOverDisplay(),
      ),
    ];
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  void _checkDamage() {
    if (_controller.planet.lastHpChange < 0 && _controller.planet.hp != _lastPlanetHp) {
      _lastPlanetHp = _controller.planet.hp;
      _colorAnimation = ColorTween(begin: Colors.red[700], end: Colors.black).animate(_animationController);
      _animationController.forward(from: 0);
      _animationControllerShake.forward(from: 0);
    }
  }

  void _startGame() {
    if (_screenSize == null) {
      _calculateScreenSize();
    }
    _controller.screenSize = _screenSize;
    _controller.start();
    _controller.planet.addListener(_checkDamage);
    _animationControllerShake.reset();
    _animationController.reset();
    _update();
  }

  void _calculateScreenSize() {
    _screenSize = MediaQuery.of(context).size;
  }

  Future<void> _onFirstFrame(Duration _) async {
    _calculateScreenSize();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_update);
    _animationControllerShake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(_update);
    _controller = GameController(
      onTick: _update,
    );
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback(_onFirstFrame);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupAnimations();
  }

  @override
  void didUpdateWidget(GameScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setupAnimations();
  }
}
