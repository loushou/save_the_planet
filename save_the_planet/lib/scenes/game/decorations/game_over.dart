import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savetheplanet/controllers/game_controller.dart';
import 'package:savetheplanet/helpers/navigation.dart';
import 'package:savetheplanet/helpers/sound.dart';
import 'package:savetheplanet/helpers/theme.dart';
import 'package:savetheplanet/widgets/effects/matrix_animation.dart';

class GameOverDisplay extends StatefulWidget {
  const GameOverDisplay();

  @override
  _GameOverDisplayState createState() => _GameOverDisplayState();
}

class _GameOverDisplayState extends State<GameOverDisplay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateNotifier>(
      builder: (BuildContext context, GameStateNotifier notifier, Widget _) => AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _getOpacity(notifier.value),
        child: GestureDetector(
          onTap: () {
            if (_getOpacity(notifier.value) > 0) {
              popIfNotFirst(Navigator.of(context));
              stpBgAudioCache.fixedPlayer.stop();
              stpBgAudioCache.loop('music/menu-music.mp3', volume: 0.10);
            }
          },
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Color(0xdddddddd),
                  border: Border(
                    top: BorderSide(color: Colors.red[900], width: 3),
                    bottom: BorderSide(color: Colors.red[900], width: 3),
                  ),
                ),
                height: 150,
              ),
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'Game Over',
                      style: stpTheme.textTheme.headline2.copyWith(
                        fontSize: 50,
                        color: Colors.red[900],
                        shadows: <Shadow>[Shadow(color: Colors.grey[700], blurRadius: 10)],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment(0, 0.65),
                  child: AlternatingScaleAnimation(
                    startScale: 1,
                    endScale: 1.15,
                    forwardDuration: const Duration(milliseconds: 550),
                    child: Text(
                      'Tap to continue',
                      style: stpTheme.textTheme.headline2.copyWith(
                        fontSize: 16,
                        color: Colors.grey[700],
                        shadows: <Shadow>[Shadow(color: Colors.grey[700], blurRadius: 10)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getOpacity(GameState state) {
    switch (state) {
      case GameState.ending:
      case GameState.ended:
        return 1;

      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
  }
}
