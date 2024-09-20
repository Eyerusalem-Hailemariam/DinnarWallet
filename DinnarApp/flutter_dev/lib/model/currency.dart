

class Currency {
  final String name; // Name of the currency (e.g., 'United States Dollar')
  final String code; // Currency code (e.g., 'USD')
  final String symbol; // Currency symbol (e.g., '$')
  final double
      exchangeRate; // Exchange rate relative to a base currency (e.g., USD)

  Currency({
    required this.name,
    required this.code,
    required this.symbol,
    required this.exchangeRate,
  });

  // List of supported currencies with exchange rates
  static List<Currency> currencies = [
    Currency(
        name: 'United States Dollar',
        code: 'USD',
        symbol: '\$',
        exchangeRate: 1.0), // base currency
    Currency(name: 'Euro', code: 'EUR', symbol: '€', exchangeRate: 0.9027),
    Currency(
        name: 'British Pound', code: 'GBP', symbol: '£', exchangeRate: 0.7620),
    Currency(
        name: 'Japanese Yen',
        code: 'JPY',
        symbol: '¥',
        exchangeRate: 140.9331), // Example exchange rate
    // Add more currencies as needed
  ];

  // Get the selected currency based on the current code
  static Currency getByCode(String code) {
    return currencies.firstWhere((currency) => currency.code == code,
        orElse: () => currencies.first);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
