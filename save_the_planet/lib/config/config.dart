class STPConfig {
  factory STPConfig() => _instance;
  STPConfig._internal();
  static final STPConfig _instance = STPConfig._internal();
}
