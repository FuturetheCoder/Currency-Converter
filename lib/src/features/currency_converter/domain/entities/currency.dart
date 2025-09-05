/// Represents a currency entity in the domain layer.
class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flagUrl;
  final double rate;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flagUrl,
    this.rate = 1.0,
  });

  /// Creates a copy of this currency with the given fields replaced by the new values.
  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    String? flagUrl,
    double? rate,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      flagUrl: flagUrl ?? this.flagUrl,
      rate: rate ?? this.rate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name &&
          symbol == other.symbol &&
          flagUrl == other.flagUrl &&
          rate == other.rate;

  @override
  int get hashCode =>
      code.hashCode ^
      name.hashCode ^
      symbol.hashCode ^
      flagUrl.hashCode ^
      rate.hashCode;

  @override
  String toString() {
    return 'Currency{code: $code, name: $name, symbol: $symbol, rate: $rate}';
  }
}
