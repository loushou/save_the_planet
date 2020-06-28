import 'package:flutter/material.dart';
import 'package:savetheplanet/helpers/screen.dart';
import 'package:savetheplanet/helpers/sound.dart';
import 'package:savetheplanet/helpers/theme.dart';
import 'package:savetheplanet/widgets/effects/matrix_animation.dart';
import 'package:savetheplanet/widgets/game_elements/planet.dart';

class MenuScene extends StatefulWidget {
  const MenuScene();

  @override
  _MenuSceneState createState() => _MenuSceneState();
}

class _MenuSceneState extends State<MenuScene> {
  @override
  Widget build(BuildContext context) {
    final double size = 300;
    return wrapScreen(
      child: Stack(
        children: <Widget>[
          Container(height: double.infinity),
          Center(
            child: PlanetElement(
              height: size,
              width: size,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment(0, 0.65),
              child: AlternatingScaleAnimation(
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/game');
                    stpBgAudioCache.fixedPlayer.stop();
                    stpBgAudioCache.loop('music/music.mp3', volume: 0.08);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      border: Border.all(color: Colors.red[900], width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                    child: Text(
                      'PLAY',
                      style: stpTheme.textTheme.button.copyWith(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ),
                startScale: 1,
                endScale: 1.1,
                forwardDuration: Duration(milliseconds: 500),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment(0, -0.75),
              child: Text(
                'SAVE THE',
                style: stpTheme.textTheme.headline5.copyWith(
                  color: Colors.red[800],
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment(0, -0.65),
              child: Text(
                'PLANET',
                style: stpTheme.textTheme.headline5.copyWith(
                  color: Colors.red,
                  fontSize: 90,
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.blueAccent,
                      blurRadius: 70,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    stpBgAudioCache.loop('music/menu-music.mp3', volume: 0.1);
  }

  @override
  void dispose() {
    stpBgAudioCache.fixedPlayer.stop();
    super.dispose();
  }
}
