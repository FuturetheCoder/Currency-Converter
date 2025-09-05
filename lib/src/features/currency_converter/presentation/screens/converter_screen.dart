import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_converter/src/features/currency_converter/presentation/providers/currency_provider.dart';
import 'package:currency_converter/src/features/currency_converter/presentation/widgets/amount_text_field.dart';
import 'package:currency_converter/src/features/currency_converter/presentation/widgets/currency_dropdown.dart';

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _convertedAmountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _convertedAmountController = TextEditingController();
    
    // Set initial amount after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(currencyConverterProvider);
      if (state.amount > 0) {
        _amountController.text = state.amount.toStringAsFixed(2);
        _updateConvertedAmount(state);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _convertedAmountController.dispose();
    super.dispose();
  }

  void _updateConvertedAmount(CurrencyConverterState state) {
    if (state.convertedAmount > 0 && state.exchangeRate != null) {
      _convertedAmountController.text = state.convertedAmount.toStringAsFixed(2);
    } else {
      _convertedAmountController.clear();
    }
  }
  
  // Format amount with proper decimal places
  String _formatAmount(String value) {
    if (value.isEmpty) return '0.00';
    
    // Remove any non-digit characters except decimal point
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Handle multiple decimal points
    final parts = cleanValue.split('.');
    if (parts.length > 2) {
      return '${parts[0]}.${parts[1]}';
    }
    
    // Limit to 2 decimal places
    if (parts.length == 2 && parts[1].length > 2) {
      return '${parts[0]}.${parts[1].substring(0, 2)}';
    }
    
    return cleanValue;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyConverterProvider);
    final notifier = ref.read(currencyConverterProvider.notifier);
    final theme = Theme.of(context);

    // Update converted amount when state changes
    if (state.amount > 0 && state.convertedAmount > 0) {
      _updateConvertedAmount(state);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and subtitle
            Text(
              'Currency Converter',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check live rates, set rate alerts, receive notifications and more',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 32),

            // Amount input section
            AmountTextField(
              key: const Key('amount_input_field'),
              label: 'Amount',
              controller: _amountController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final formattedValue = _formatAmount(value);
                  final amount = double.tryParse(formattedValue) ?? 0;
                  if (amount >= 0) {
                    notifier.setAmount(amount.toString());
                  }
                } else {
                  notifier.setAmount('0');
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              amountStyle: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              hintText: '0.00',
            ),
            const SizedBox(height: 16),

            // Currency selection row
            Row(
              children: [
                // From currency dropdown
                Expanded(
                  flex: 3,
                  child: CurrencyDropdown(
                    selectedCurrency: state.fromCurrency,
                    currencies: state.currencies,
                    onChanged: (currency) {
                      notifier.setFromCurrency(currency);
                    },
                    isFromCurrency: true,
                    isLoading: state.isLoading,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Swap button
            if (state.fromCurrency != null && state.toCurrency != null)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  key: const Key('swap_currencies_button'),
                  icon: Icon(
                    Icons.swap_vert_rounded,
                    color: theme.colorScheme.onPrimary,
                  ),
                  onPressed: state.isLoading
                      ? null
                      : () {
                          notifier.swapCurrencies();
                          // Update the amount field to trigger a rebuild
                          final amount = _amountController.text;
                          _amountController.text = _convertedAmountController.text;
                          _convertedAmountController.text = amount;
                        },
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              )
            else
              const SizedBox(width: 56), // Placeholder to maintain layout
                const SizedBox(width: 16),
                
                // To currency dropdown
                Expanded(
                  flex: 3,
                  child: CurrencyDropdown(
                    selectedCurrency: state.toCurrency,
                    currencies: state.currencies,
                    onChanged: (currency) {
                      notifier.setToCurrency(currency);
                    },
                    isFromCurrency: false,
                    isLoading: state.isLoading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Converted amount section
            AmountTextField(
              label: 'Converted Amount',
              controller: _convertedAmountController,
              readOnly: true,
              amountStyle: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Exchange rate information
            if (state.exchangeRate != null && state.fromCurrency != null && state.toCurrency != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    '1 ${state.fromCurrency!.code} = ${state.exchangeRate!.toStringAsFixed(4)} ${state.toCurrency!.code}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Error message
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  state.error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
