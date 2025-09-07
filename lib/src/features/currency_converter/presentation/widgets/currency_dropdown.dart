import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:currency_converter/src/features/currency_converter/domain/entities/currency.dart';

class CurrencyDropdown extends StatelessWidget {
  final Currency? selectedCurrency;
  final List<Currency> currencies;
  final ValueChanged<Currency?> onChanged;
  final bool isFromCurrency;
  final bool isLoading;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onChanged,
    this.isFromCurrency = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<Currency>(
    isDense: false,

      initialValue: selectedCurrency,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            // ignore: deprecated_member_use
            color: Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.transparent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        
      ),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.keyboard_arrow_down_rounded),
      items: currencies.map((Currency currency) {
        return DropdownMenuItem<Currency>(
          value: currency,
          child: Row(
            children: [
              // Display currency flag
              if (currency.flagUrl.endsWith('.svg'))
                ClipOval(
                  child: SvgPicture.network(
                    currency.flagUrl,
                    width: 25,
                    height: 80,
                    placeholderBuilder: (context) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                    ),
                  ),
                )
              else
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: currency.flagUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,

                    placeholder: (context, url) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 24,
                      height: 24,
                      color: Colors.grey[200],
                      child: const Icon(Icons.flag, size: 20),
                    ),
                  ),
                ),

              const SizedBox(width: 8),
              Text(
                currency.code,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF26278D),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => onChanged(value),
    );
  }
}
