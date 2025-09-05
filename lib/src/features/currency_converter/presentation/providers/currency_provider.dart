import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_converter/src/features/currency_converter/domain/entities/currency.dart';
import 'package:currency_converter/src/features/currency_converter/domain/repositories/currency_repository.dart';
import 'package:currency_converter/src/features/currency_converter/data/repositories/currency_repository_impl.dart';

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepositoryImpl();
});

final currencyConverterProvider = StateNotifierProvider<CurrencyConverterNotifier, CurrencyConverterState>((ref) {
  final repository = ref.watch(currencyRepositoryProvider);
  return CurrencyConverterNotifier(repository);
});

class CurrencyConverterNotifier extends StateNotifier<CurrencyConverterState> {
  final CurrencyRepository _repository;
  
  CurrencyConverterNotifier(this._repository) : super(CurrencyConverterState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final currencies = _repository.getSupportedCurrencies();
      if (currencies.isNotEmpty) {
        state = state.copyWith(
          fromCurrency: currencies.firstWhere(
            (c) => c.code == 'SGD', 
            orElse: () => currencies.first,
          ),
          toCurrency: currencies.firstWhere(
            (c) => c.code == 'USD', 
            orElse: () => currencies[1],
          ),
          currencies: currencies,
        );
        
        // Fetch initial exchange rate
        await updateExchangeRate();
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize currencies: $e',
      );
    }
  }

  void setAmount(String amount) {
    final parsedAmount = double.tryParse(amount) ?? 0.0;
    state = state.copyWith(amount: parsedAmount);
    _updateConvertedAmount();
  }

  void setFromCurrency(Currency? currency) {
    if (currency == null) return;
    state = state.copyWith(fromCurrency: currency);
    updateExchangeRate();
  }

  void setToCurrency(Currency? currency) {
    if (currency == null) return;
    state = state.copyWith(toCurrency: currency);
    updateExchangeRate();
  }

  void swapCurrencies() {
    if (state.fromCurrency != null && state.toCurrency != null) {
      final temp = state.fromCurrency!;
      state = state.copyWith(
        fromCurrency: state.toCurrency!,
        toCurrency: temp,
      );
      updateExchangeRate();
    }
  }

  Future<void> updateExchangeRate() async {
    if (state.fromCurrency == null || state.toCurrency == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final rate = await _repository.convertCurrency(
        fromCurrency: state.fromCurrency!.code,
        toCurrency: state.toCurrency!.code,
        amount: 1.0,
      );
      
      state = state.copyWith(
        exchangeRate: rate,
        convertedAmount: state.amount * rate,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update exchange rate: $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _updateConvertedAmount() {
    if (state.exchangeRate == null) return;
    state = state.copyWith(
      convertedAmount: state.amount * state.exchangeRate!,
    );
  }
}

class CurrencyConverterState {
  final Currency? fromCurrency;
  final Currency? toCurrency;
  final double amount;
  final double? exchangeRate;
  final double convertedAmount;
  final bool isLoading;
  final String? error;
  final List<Currency> currencies;

  CurrencyConverterState({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.exchangeRate,
    required this.convertedAmount,
    required this.isLoading,
    required this.error,
    required this.currencies,
  });

  factory CurrencyConverterState.initial() {
    return CurrencyConverterState(
      fromCurrency: null,
      toCurrency: null,
      amount: 1000.0, // Default amount as shown in the image
      exchangeRate: null,
      convertedAmount: 0.0,
      isLoading: false,
      error: null,
      currencies: [],
    );
  }

  CurrencyConverterState copyWith({
    Currency? fromCurrency,
    Currency? toCurrency,
    double? amount,
    double? exchangeRate,
    double? convertedAmount,
    bool? isLoading,
    String? error,
    List<Currency>? currencies,
  }) {
    return CurrencyConverterState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currencies: currencies ?? this.currencies,
    );
  }
}
