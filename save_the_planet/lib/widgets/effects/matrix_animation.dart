import 'dart:async';

import 'package:flutter/material.dart';
import 'package:savetheplanet/helpers/math.dart';

class AnimatedMatrix extends StatefulWidget {
  const AnimatedMatrix({
    Key key,
    @required this.duration,
    @required this.matrix,
    @required this.child,
    this.alignment = Alignment.center,
    this.curve = Curves.easeInOut,
    this.onComplete,
  }) : super(key: key);

  final Duration duration;
  final Matrix4 matrix;
  final AlignmentGeometry alignment;
  final Widget child;
  final Curve curve;
  final VoidCallback onComplete;

  @override
  _AnimatedMatrixState createState() => _AnimatedMatrixState();
}

class _AnimatedMatrixState extends State<AnimatedMatrix> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Matrix4> _animation;
  Matrix4 _lastMatrix = Matrix4.identity();
  int id;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: _animation.value,
      alignment: widget.alignment,
      child: widget.child,
    );
  }

  void _setupAnimation() {
    final Matrix4 lastMatrix = _lastMatrix?.clone() ?? Matrix4.identity();

    if (_controller is! AnimationController) {
      _controller = AnimationController(
        vsync: this,
        lowerBound: 0,
        upperBound: 1,
      )
        ..addListener(() {
          _update();
        })
        ..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed && widget.onComplete != null) {
            widget.onComplete();
          }
        });
    }

    _controller.duration = widget.duration;
    final Animation<double> curve = CurvedAnimation(parent: _controller, curve: widget.curve);
    _animation = Tween<Matrix4>(
      begin: lastMatrix,
      end: widget.matrix ?? Matrix4.identity(),
    ).animate(curve);
    _lastMatrix = widget.matrix;
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  void _destroyAnimation() {
    _lastMatrix = null;
    _controller?.dispose();
    _controller = null;
  }

  void _resetAnimation() {
    _controller?.dispose();
    _controller = null;
  }

  Future<void> _onFirstFrame(Duration _) async {
    _controller.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    id = randomInt(0, 10000000);

    _lastMatrix = widget.matrix;

    WidgetsBinding.instance.addPostFrameCallback(_onFirstFrame);

    _setupAnimation();
  }

  @override
  void dispose() {
    _destroyAnimation();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedMatrix oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matrix != oldWidget.matrix) {
      _resetAnimation();
      _setupAnimation();
      _onFirstFrame(null);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetAnimation();
    _setupAnimation();
  }
}

class AlternatingScaleAnimation extends StatefulWidget {
  const AlternatingScaleAnimation({
    Key key,
    @required this.child,
    this.startScale = 1,
    this.endScale = 1,
    this.forwardDuration = const Duration(seconds: 1),
    this.backwardDuration,
    this.alignment = Alignment.center,
    this.curve = Curves.linear,
  }) : super(key: key);

  final Widget child;
  final double startScale;
  final double endScale;
  final Duration forwardDuration;
  final Duration backwardDuration;
  final Alignment alignment;
  final Curve curve;

  @override
  _AlternatingScaleAnimationState createState() => _AlternatingScaleAnimationState();
}

class _AlternatingScaleAnimationState extends State<AlternatingScaleAnimation> {
  Timer _timer;
  bool _forward = false;
  int id;

  Duration get fDur => widget.forwardDuration;

  Duration get bDur => widget.backwardDuration ?? widget.forwardDuration;

  Matrix4 get fMat => Matrix4.identity()..scale(widget.endScale, widget.endScale);

  Matrix4 get bMat => Matrix4.identity()..scale(widget.startScale, widget.startScale);

  @override
  Widget build(BuildContext context) {
    return AnimatedMatrix(
      key: ValueKey<String>('alternating-$id'),
      duration: _forward ? fDur : bDur,
      matrix: _forward ? fMat : bMat,
      child: widget.child,
      alignment: widget.alignment,
      curve: widget.curve,
    );
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  void _switch() {
    if (_forward) {
      _timer = Timer(
        widget.backwardDuration ?? widget.forwardDuration,
        () {
          _switch();
        },
      );
    } else {
      _timer = Timer(
        widget.forwardDuration,
        () {
          _switch();
        },
      );
    }
    _forward = !_forward;
    _update();
  }

  void _setupAnimation() {
    _switch();
  }

  void _destroyAnimation() {
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    id = randomInt(0, 10000000);
    _setupAnimation();
  }

  @override
  void dispose() {
    _destroyAnimation();
    super.dispose();
  }

  @override
  void didUpdateWidget(AlternatingScaleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

class UnidirectionalScaleAnimation extends StatefulWidget {
  const UnidirectionalScaleAnimation({
    @required this.child,
    this.startScale = 1,
    this.endScale = 1,
    this.forwardDuration = const Duration(seconds: 1),
    this.alignment = Alignment.center,
    this.curve = Curves.linear,
    this.onComplete,
  });

  final Widget child;
  final double startScale;
  final double endScale;
  final Duration forwardDuration;
  final Alignment alignment;
  final Curve curve;
  final VoidCallback onComplete;

  @override
  _UnidirectionalScaleAnimationState createState() => _UnidirectionalScaleAnimationState();
}

class _UnidirectionalScaleAnimationState extends State<UnidirectionalScaleAnimation> {
  bool _started = false;

  Duration get fDur => widget.forwardDuration;

  Matrix4 get starting => Matrix4.identity()..scale(widget.startScale, widget.startScale);

  Matrix4 get ending => Matrix4.identity()..scale(widget.endScale, widget.endScale);

  @override
  Widget build(BuildContext context) {
    return AnimatedMatrix(
      key: ValueKey<Widget>(widget.child),
      duration: fDur,
      matrix: _started ? ending : starting,
      child: widget.child,
      alignment: widget.alignment,
      curve: widget.curve,
      onComplete: _started ? widget.onComplete : () {},
    );
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onFirstFrame(Duration _) async {
    Timer(
      const Duration(milliseconds: 500),
      () {
        _started = true;
        _update();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onFirstFrame);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
