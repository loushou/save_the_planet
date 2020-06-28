abstract class HasHealth {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory HasHealth._() => null;

  double get hp;
  double get maxHp;
  double get percentHp => hp / maxHp;
}
