import 'dart:math';

import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/mixins/has_health.dart';

class HealthBar extends StatelessWidget {
  const HealthBar({
    this.actor,
    this.barSize = 5,
    this.barCount = 5,
  });

  final HasHealth actor;
  final double barSize;
  final int barCount;

  @override
  Widget build(BuildContext context) {
    final Color healthColor = _getColor();
    final int currentBarCount = _getBarCount();
    final List<Widget> children = List<Widget>.filled(
      currentBarCount,
      Container(
        height: barSize,
        width: barSize,
        color: healthColor,
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 1),
      ),
      growable: true,
    );
    if (children.isEmpty) {
      children.add(Container());
    }

    return Container(
      width: (barSize + 2) * barCount,
      height: barSize,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  int _getBarCount() => actor.percentHp == 0 ? 0 : max(1, actor.percentHp ~/ (1 / barCount));

  Color _getColor() {
    if (actor.percentHp < 0.25) {
      return Colors.red;
    } else if (actor.percentHp < 0.7) {
      return Colors.yellow;
    }
    return Colors.green;
  }
}
