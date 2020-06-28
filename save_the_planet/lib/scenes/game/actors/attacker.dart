import 'dart:math';

import 'package:flutter/material.dart';
import 'package:savetheplanet/controllers/notifiers/attacker.dart';
import 'package:savetheplanet/helpers/math.dart';
import 'package:savetheplanet/widgets/effects/matrix_animation.dart';

class AttackerDisplay extends StatefulWidget {
  const AttackerDisplay({
    Key key,
    this.attacker,
  }) : super(key: key);

  final Attacker attacker;

  @override
  _AttackerDisplayState createState() => _AttackerDisplayState();
}

class _AttackerDisplayState extends State<AttackerDisplay> with TickerProviderStateMixin {
  Attacker _attacker;
  AnimationController _controller;
  Matrix4 _matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    final double width = 2 + (_attacker.radiusSize * 2);
    final bool dieing = _attacker.state == AttackerState.dieing;
    final Color color = dieing ? Colors.grey[800] : Colors.transparent;
    final BlendMode mode = dieing ? BlendMode.srcATop : BlendMode.color;

    final Widget image = ColorFiltered(
      colorFilter: ColorFilter.mode(
        color,
        mode,
      ),
      child: Image.asset(
        'assets/actors/corona.png',
        width: width,
        height: width,
      ),
    );

    final Matrix4 matrix = _matrix.clone();
    if (dieing) {
      matrix.scale(0.85, 0.85);
    }
    return Transform.translate(
      offset: Offset(-width / 2, -width / 2),
      child: Transform.rotate(
        angle: _attacker.spin * (_controller?.value ?? 0) * (2 * pi),
        child: AnimatedMatrix(
          matrix: matrix,
          duration: const Duration(milliseconds: 350),
          child: image,
        ),
      ),
    );
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _attacker = widget.attacker;
    widget.attacker.addListener(_update);
    _controller = AnimationController(
      vsync: this,
    );
    _controller.repeat(period: Duration(milliseconds: randomInt(3000, 5000)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AttackerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attacker = widget.attacker;
  }
}
