class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flagUrl;
  final double rate; // Rate compared to base currency (USD)

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flagUrl,
    this.rate = 1.0,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      flagUrl: json['flagUrl'] as String,
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'flagUrl': flagUrl,
      'rate': rate,
    };
  }

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
}

// Common currencies with their codes, names, symbols, and flag URLs
final List<Currency> commonCurrencies = [
  const Currency(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    flagUrl: 'https://flagcdn.com/w40/us.png',
  ),
  const Currency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    flagUrl: 'https://flagcdn.com/w40/eu.png',
  ),
  const Currency(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    flagUrl: 'https://flagcdn.com/w40/gb.png',
  ),
  const Currency(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    flagUrl: 'https://flagcdn.com/w40/jp.png',
  ),
  const Currency(
    code: 'SGD',
    name: 'Singapore Dollar',
    symbol: 'S\$',
    flagUrl: 'https://flagcdn.com/w40/sg.png',
  ),
  const Currency(
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A\$',
    flagUrl: 'https://flagcdn.com/w40/au.png',
  ),
  const Currency(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
    flagUrl: 'https://flagcdn.com/w40/ca.png',
  ),
  const Currency(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    flagUrl: 'https://flagcdn.com/w40/cn.png',
  ),
  const Currency(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
    flagUrl: 'https://flagcdn.com/w40/in.png',
  ),
];
