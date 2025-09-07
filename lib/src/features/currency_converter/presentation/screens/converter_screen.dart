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
      _convertedAmountController.text = state.convertedAmount.toStringAsFixed(
        2,
      );
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
      backgroundColor: Colors.transparent,
      body: Container(
        
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF3FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 12),
              Text(
                'Currency Converter',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF1F2261),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Check live rates, set rate alerts, receive notifications and more',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 32),

              // Amount input sectionrr
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Amount',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              //height:85,
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
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: AmountTextField(
                              key: const Key('amount_input_field'),

                              controller: _amountController,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final formattedValue = _formatAmount(value);
                                  final amount =
                                      double.tryParse(formattedValue) ?? 0;
                                  if (amount >= 0) {
                                    notifier.setAmount(amount.toString());
                                  }
                                } else {
                                  notifier.setAmount('0');
                                }
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],

                              amountStyle: theme.textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              hintText: '0.00',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment
                            .center, // centers children over each other
                        children: [
                          // Divider in the background
                          const Divider(
                            thickness: 1,
                            color: Color(0xFFE7E7EE),
                            indent: 16,
                            endIndent: 16,
                          ),

                          // Centered Row holding the button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (state.fromCurrency != null &&
                                  state.toCurrency != null)
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.3),
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
                                            final amount =
                                                _amountController.text;
                                            _amountController.text =
                                                _convertedAmountController.text;
                                            _convertedAmountController.text =
                                                amount;
                                          },
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF1F2261),
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                      disabledBackgroundColor: theme
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 56),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Converted Amount',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),

                      Row(
                        children: [
                          Expanded(
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              child: AmountTextField(
                                controller: _convertedAmountController,
                                readOnly: true,
                                amountStyle: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                     
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

Align(
  alignment: Alignment.bottomLeft,
  child: Column(
   
    children: [

      SizedBox(height: 30),
      if (state.exchangeRate != null &&
                    state.fromCurrency != null &&
                    state.toCurrency != null)
  
                    Text('Indicative Exchange Rate',style: theme.textTheme.bodyMedium?.copyWith(
                      color:Color(0xFF9B9B9B),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '1 ${state.fromCurrency!.code} = ${state.exchangeRate!.toStringAsFixed(4)} ${state.toCurrency!.code}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18
                      ),
                      textAlign: TextAlign.center,
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
    ],),
),
              // Exchange rate information
              
            ],
          ),
        ),
      ),
    );
  }
}
