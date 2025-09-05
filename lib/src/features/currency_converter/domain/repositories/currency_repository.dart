import 'package:currency_converter/src/features/currency_converter/domain/entities/currency.dart';

/// Defines the interface for currency-related operations
abstract class CurrencyRepository {
  /// Fetches exchange rates for the given base currency
  Future<Map<String, double>> getExchangeRates(String baseCurrency);
  
  /// Converts an amount from one currency to another
  Future<double> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  });
  
  /// Returns a list of all supported currencies with their details
  List<Currency> getSupportedCurrencies();
  
  /// Finds a currency by its code (e.g., 'USD', 'EUR')
  Currency? getCurrencyByCode(String code);
  
  /// Releases any resources used by the repository
  void dispose();
}
