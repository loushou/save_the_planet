import 'dart:math';

import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/planet.dart';
import 'package:savetheplanet/scenes/game/decorations/health_bar.dart';
import 'package:savetheplanet/widgets/game_elements/planet.dart';

class PlanetDisplay extends StatelessWidget {
  const PlanetDisplay({
    this.planet,
  });

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    if (planet == null) {
      return Container();
    }

    return Stack(
      children: <Widget>[
        PlanetElement(
          height: planet.radiusSize * 2,
          width: planet.radiusSize * 2,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, 10),
              child: HealthBar(
                actor: planet,
                barSize: 4,
                barCount: max(0, (planet.radiusSize * 2) ~/ 6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
