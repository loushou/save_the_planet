import 'package:flutter/material.dart';

class AnchoredHud extends StatelessWidget {
  const AnchoredHud({
    this.child,
    this.adjust = Offset.zero,
    this.anchor = Alignment.center,
  });

  final Alignment anchor;
  final Offset adjust;
  final Widget child;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Align(
          alignment: anchor,
          child: Transform.translate(
            offset: adjust,
            child: child,
          ),
        ),
      );
}

class BottomAnchoredHud extends StatelessWidget {
  const BottomAnchoredHud({
    this.child,
    this.adjust = Offset.zero,
  });

  final Offset adjust;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnchoredHud(
        child: child,
        adjust: adjust,
        anchor: Alignment.bottomCenter,
      );
}

class TopAnchoredHud extends StatelessWidget {
  const TopAnchoredHud({
    this.child,
    this.adjust = Offset.zero,
  });

  final Offset adjust;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnchoredHud(
        child: child,
        adjust: adjust,
        anchor: Alignment.topCenter,
      );
}
