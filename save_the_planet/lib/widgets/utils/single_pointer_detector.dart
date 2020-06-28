import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SinglePointerPanDetector extends StatelessWidget {
  const SinglePointerPanDetector({
    this.child,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.behavior,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  final Widget child;
  final GestureDragDownCallback onPanDown;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final GestureDragCancelCallback onPanCancel;
  final DragStartBehavior dragStartBehavior;
  final HitTestBehavior behavior;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures = <Type, GestureRecognizerFactory>{};

    if (onPanDown != null || onPanStart != null || onPanUpdate != null || onPanEnd != null || onPanCancel != null) {
      gestures[_SingleTouchPanRecognizer] = GestureRecognizerFactoryWithHandlers<_SingleTouchPanRecognizer>(
        () => _SingleTouchPanRecognizer(debugOwner: this),
        (_SingleTouchPanRecognizer instance) {
          instance
            ..onDown = onPanDown
            ..onStart = onPanStart
            ..onUpdate = onPanUpdate
            ..onEnd = onPanEnd
            ..onCancel = onPanCancel
            ..dragStartBehavior = dragStartBehavior;
        },
      );
    }

    return RawGestureDetector(
      gestures: gestures,
      behavior: behavior,
      excludeFromSemantics: excludeFromSemantics,
      child: child,
    );
  }
}

class _SingleTouchPanRecognizer extends PanGestureRecognizer {
  _SingleTouchPanRecognizer({Object debugOwner}) : super(debugOwner: debugOwner);

  int _p = 0;

  @override
  void addAllowedPointer(PointerEvent event) {
    // first register the current pointer so that related events will be handled by this recognizer
    startTrackingPointer(event.pointer);

    if (_p == 0) {
      // if no pointer is tracked, already, use this one
      resolve(GestureDisposition.rejected);
      _p = event.pointer;
      super.addAllowedPointer(event);
    } else if (_p == event.pointer) {
      // reject tracking of another pointer
      resolve(GestureDisposition.accepted);
    } else {
      resolve(GestureDisposition.rejected);
    }
  }

  @override
  String get debugDescription => null;

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _p) {
      return;
    }
    // TODO: implement handleEvent
    super.handleEvent(event);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    if (_p == pointer) {
      _p = 0;
      super.didStopTrackingLastPointer(pointer);
    }
  }
}
