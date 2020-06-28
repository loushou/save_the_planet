import 'dart:math';

import 'package:flutter/material.dart';

class BoundScaleFactor extends StatelessWidget {
  const BoundScaleFactor({
    this.child,
    this.maxFactor = 1.5,
    this.minFactor = 0.5,
  });

  final Widget child;
  final double maxFactor;
  final double minFactor;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    final double factor = max(min(data.textScaleFactor, maxFactor), minFactor);
    return MediaQuery(
      child: child,
      data: data.copyWith(textScaleFactor: factor),
    );
  }
}
