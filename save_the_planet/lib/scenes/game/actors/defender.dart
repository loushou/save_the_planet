import 'dart:math';

import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/defender.dart';
import 'package:savetheplanet/helpers/math.dart';
import 'package:savetheplanet/scenes/game/decorations/anchors.dart';
import 'package:savetheplanet/scenes/game/decorations/health_bar.dart';

const Size _minTouchSize = Size(40, 40);

class DefenderDisplay extends StatefulWidget {
  const DefenderDisplay({
    this.defender,
  });

  final Defender defender;

  @override
  _DefenderDisplayState createState() => _DefenderDisplayState();
}

class _DefenderDisplayState extends State<DefenderDisplay> {
  @override
  Widget build(BuildContext context) {
    final Size defenderSize = Size(widget.defender.radiusSize * 2, widget.defender.radiusSize * 2);
    final Size touchSize = maxSize(defenderSize, _minTouchSize);
    return Transform.translate(
      offset: Offset(-touchSize.width / 2, -touchSize.height / 2),
      child: Stack(
        children: <Widget>[
          Container(
            width: touchSize.width,
            height: touchSize.height,
            child: Center(
              child: Transform.rotate(
                angle: widget.defender.rotation + (pi / 2),
                child: SizedBox(
                  height: widget.defender.radiusSize,
                  width: widget.defender.radiusSize,
                  child: CustomPaint(
                    painter: ShipPainter(_defenderColor(widget.defender)),
                  ),
                ),
              ),
            ),
          ),
          BottomAnchoredHud(
            child: HealthBar(
              actor: widget.defender,
              barSize: 4,
              barCount: 6,
            ),
          ),
          _getDragHelper(context),
        ],
      ),
    );
  }

  Widget _getDragHelper(BuildContext context) {
    if (!widget.defender.moving) {
      return Container();
    }

    final Offset vector = widget.defender.position - pointFromOriginAtAngleAndDistance(widget.defender.position, widget.defender.rotation, 1);
    final Alignment alignment = Alignment(-vector.dx * 3.5, -vector.dy * 3.5);
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Transform.rotate(
          angle: widget.defender.rotation,
          child: Transform.rotate(
            angle: (pi * 0.75),
            child: Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.green, width: 2),
                  left: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _defenderColor(Defender defender) {
    switch (defender.state) {
      case DefenderState.spawning:
        return const Color(0x88fbc02d);
      case DefenderState.spawned:
        return const Color(0xfffbc02d);
      case DefenderState.dieing:
        return const Color(0x88c62828);
      case DefenderState.dead:
        return const Color(0xffc62828);
      default:
        return Colors.transparent;
    }
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    widget.defender.addListener(_update);
  }
}

class ShipPainter extends CustomPainter {
  ShipPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height * .8);
    path.lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ShipPainter oldDelegate) => false;
}
