import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savetheplanet/controllers/game_controller.dart';
import 'package:savetheplanet/helpers/theme.dart';

class HUDLevel extends StatelessWidget {
  const HUDLevel();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'LEVEL: ',
              style: stpTheme.textTheme.bodyText2.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Consumer<LevelNotifier>(
              builder: (BuildContext context, LevelNotifier notifier, Widget _) => Text(
                '${notifier.value}',
                style: stpTheme.textTheme.bodyText2.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
