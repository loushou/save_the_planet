import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savetheplanet/controllers/game_controller.dart';
import 'package:savetheplanet/helpers/math.dart';
import 'package:savetheplanet/widgets/utils/single_pointer_detector.dart';

class DragDetector extends StatefulWidget {
  const DragDetector({
    this.child,
  });

  final Widget child;

  @override
  _DragDetectorState createState() => _DragDetectorState();
}

class _DragDetectorState extends State<DragDetector> {
  Defender _currentDefender;

  @override
  Widget build(BuildContext context) {
    return SinglePointerPanDetector(
      child: widget.child,
      onPanStart: _onStart,
      onPanUpdate: _onUpdate,
      onPanEnd: _onEnd,
    );
  }

  void _onStart(DragStartDetails details) {
    if (_currentDefender != null) {
      return;
    }

    final GameController controller = Provider.of<GameController>(context, listen: false);
    if (controller == null) {
      return;
    }

    int i;
    for (i = 0; i < controller.defenders.length; i += 1) {
      if (controller.defenders[i].pointWithinBounds(details.globalPosition)) {
        _currentDefender = controller.defenders[i];
        _currentDefender.moving = true;
        break;
      }
    }
  }

  void _onUpdate(DragUpdateDetails details) {
    if (_currentDefender != null && _currentDefender.moving && _currentDefender.canCollide) {
      _currentDefender.position += details.delta;

      // attempt to smooth seemingly random changes in angle
      final double intensity = distanceFormula(Offset.zero, details.delta);
      final double maxChng = intensity * (pi / 60);
      double current = _currentDefender.rotation;
      double newAngle = radiansFromDelta(details.delta);

      if ((current - newAngle).abs() > pi) {
        if (current > newAngle) {
          newAngle += (pi * 2);
        } else if (newAngle > current) {
          current += (pi * 2);
        }
      }
      newAngle = (newAngle > current ? 1 : -1) * maxChng;
      newAngle += current;

      _currentDefender.rotation = ((current + newAngle) / 2) % (2 * pi);
    }
  }

  void _onEnd(DragEndDetails details) {
    _currentDefender?.moving = false;
    _currentDefender = null;
  }
}
