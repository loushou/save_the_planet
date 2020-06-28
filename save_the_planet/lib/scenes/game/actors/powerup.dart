import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/bonus_damage.dart';
import 'package:savetheplanet/controllers/notifiers/fast_fire.dart';
import 'package:savetheplanet/controllers/notifiers/heal.dart';
import 'package:savetheplanet/controllers/notifiers/max_hp.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/power_up.dart';
import 'package:savetheplanet/widgets/effects/matrix_animation.dart';

class PowerupDisplay extends StatelessWidget {
  const PowerupDisplay({
    this.powerup,
  });

  final PowerUp powerup;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-powerup.radiusSize, -powerup.radiusSize),
      child: AlternatingScaleAnimation(
        key: ValueKey<PowerUp>(powerup),
        startScale: 1,
        endScale: 1.25,
        forwardDuration: const Duration(milliseconds: 900),
        child: Container(
          height: powerup.radiusSize * 2,
          width: powerup.radiusSize * 2,
          decoration: BoxDecoration(
            color: Color(0xdd9c27b0),
            borderRadius: BorderRadius.circular(powerup.radiusSize),
          ),
          child: _getIcon(),
        ),
      ),
    );
  }

  Widget _getIcon() {
    if (powerup is FasterFire) {
      return Icon(
        Icons.fast_forward,
        color: Colors.white,
        size: powerup.radiusSize,
      );
    } else if (powerup is MaxHp) {
      return Icon(
        Icons.add,
        color: Colors.white,
        size: powerup.radiusSize,
      );
    } else if (powerup is BonusDamage) {
      return Icon(
        Icons.fullscreen_exit,
        color: Colors.white,
        size: powerup.radiusSize,
      );
    } else if (powerup is HealHp) {
      return Icon(
        Icons.flare,
        color: Colors.white,
        size: powerup.radiusSize,
      );
    } else {
      print('++++++++++++++++++++++++++ power up is heal? ${powerup is HealHp} ///  $powerup');
      return Icon(
        Icons.error,
        color: Colors.red,
        size: powerup.radiusSize,
      );
    }
  }
}
