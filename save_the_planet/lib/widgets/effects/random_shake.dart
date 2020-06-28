import 'package:flutter/material.dart';
import 'package:savetheplanet/helpers/math.dart';

class RandomShake extends StatefulWidget {
  const RandomShake({
    this.controller,
    this.child,
  });

  final AnimationController controller;
  final Widget child;

  @override
  _RandomShakeState createState() => _RandomShakeState();
}

class _RandomShakeState extends State<RandomShake> {
  final List<Animation<Offset>> _animations = <Animation<Offset>>[];
  final List<double> _offsets = <double>[];
  final int shakes = 12;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _getAnimation().value,
      child: widget.child,
    );
  }

  Animation<Offset> _getAnimation() {
    Animation<Offset> _animation;
    int i;
    for (i = 0; i < _offsets.length; i += 1) {
      if (widget.controller.value < _offsets[i]) {
        _animation = _animations[i];
        break;
      }
    }

    return _animation ?? _animations.last;
  }

  void _buildAnimations() {
    final double minShake = -8;
    final double maxShake = 8;
    widget.controller.removeListener(_update);
    widget.controller.addListener(_update);

    _offsets.clear();
    _animations.clear();
    int i;
    for (i = 0; i < shakes; i += 1) {
      _offsets.add(i * (1 / shakes));
      _animations.add(_buildAnimation(
        Offset(randomDouble(minShake, maxShake), randomDouble(minShake, maxShake)),
        i == 3 ? Offset.zero : Offset(randomDouble(minShake, maxShake), randomDouble(minShake, maxShake)),
        i * (1 / shakes),
        (i + 1) * (1 / shakes),
      ));
    }
  }

  Animation<Offset> _buildAnimation(Offset start, Offset finish, double from, double to) => Tween<Offset>(begin: start, end: finish).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(
        from,
        to,
        curve: Curves.bounceOut,
      )));

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  void _rebuildOnEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _buildAnimations();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addStatusListener(_rebuildOnEnd);
    _buildAnimations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildAnimations();
  }
}
