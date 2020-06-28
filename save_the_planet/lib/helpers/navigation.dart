import 'package:flutter/material.dart';

void popIfNotFirst(NavigatorState state) {
  int popped = 0;
  state.popUntil((Route<dynamic> route) {
    if (popped > 0) {
      return true;
    }

    if (!route.isFirst) {
      popped += 1;
    }

    return route.isFirst;
  });
}
