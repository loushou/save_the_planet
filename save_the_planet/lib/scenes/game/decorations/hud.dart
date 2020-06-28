import 'package:flutter/material.dart';
import 'package:savetheplanet/scenes/game/decorations/hud_elements/level.dart';
import 'package:savetheplanet/scenes/game/decorations/hud_elements/score.dart';

class GameHUD extends StatelessWidget {
  const GameHUD({
    this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        HUDScore(),
        HUDLevel(),
      ],
    );
  }
}
