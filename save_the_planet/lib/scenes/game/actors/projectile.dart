import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/projectile.dart';

class ProjectileDisplay extends StatelessWidget {
  const ProjectileDisplay({
    this.projectile,
  });

  final Projectile projectile;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-projectile.radiusSize, -projectile.radiusSize),
      child: Container(
        height: projectile.radiusSize * 2,
        width: projectile.radiusSize * 2,
        decoration: BoxDecoration(
          color: Colors.yellow[300],
          borderRadius: BorderRadius.circular(projectile.radiusSize),
        ),
      ),
    );
  }
}
