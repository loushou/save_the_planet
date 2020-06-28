abstract class Tickable {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory Tickable._() => null;

  void onTick(Duration elapsed);
}
