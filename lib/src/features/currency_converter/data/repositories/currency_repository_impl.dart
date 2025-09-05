import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:currency_converter/src/core/constants/api_constants.dart';
import 'package:currency_converter/src/features/currency_converter/domain/entities/currency.dart';
import 'package:currency_converter/src/features/currency_converter/domain/repositories/currency_repository.dart';

// Import the model to access the commonCurrencies list
import 'package:currency_converter/src/features/currency_converter/data/models/currency_model.dart' as model;

class CurrencyRepositoryImpl implements CurrencyRepository {
  final http.Client client;

  CurrencyRepositoryImpl({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    try {
      final response = await client.get(
        Uri.parse(ApiConstants.getLatestRatesUrl(baseCurrency)),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['result'] == 'success') {
          final Map<String, dynamic> rates = data['conversion_rates'];
          return rates.map((key, value) => MapEntry(key, value.toDouble()));
        } else {
          throw Exception('Failed to fetch exchange rates: ${data['error-type']}');
        }
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<double> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    try {
      final response = await client.get(
        Uri.parse(
          ApiConstants.getPairConversionUrl(fromCurrency, toCurrency, amount),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['result'] == 'success') {
          return (data['conversion_result'] as num).toDouble();
        } else {
          throw Exception('Conversion failed: ${data['error-type']}');
        }
      } else {
        throw Exception('Failed to perform conversion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  List<Currency> getSupportedCurrencies() {
    // Convert the model currencies to domain entities
    return model.commonCurrencies.map((currency) => Currency(
      code: currency.code,
      name: currency.name,
      symbol: currency.symbol,
      flagUrl: currency.flagUrl,
      rate: currency.rate,
    )).toList();
  }

  @override
  Currency? getCurrencyByCode(String code) {
    try {
      final currency = model.commonCurrencies.firstWhere(
        (c) => c.code == code,
        orElse: () => throw Exception('Currency not found'),
      );
      return Currency(
        code: currency.code,
        name: currency.name,
        symbol: currency.symbol,
        flagUrl: currency.flagUrl,
        rate: currency.rate,
      );
    } catch (e) {
      return null;
    }
  }
  
  @override
  void dispose() {
    client.close();
  }
}
