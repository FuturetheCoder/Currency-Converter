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
      initialValue: selectedCurrency,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            // ignore: deprecated_member_use
            color: theme.dividerColor.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            // ignore: deprecated_member_use
            color: theme.dividerColor.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
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
                SvgPicture.network(
                  currency.flagUrl,
                  width: 24,
                  height: 24,
                  placeholderBuilder: (context) => Container(
                    width: 24,
                    height: 24,
                    color: Colors.grey[200],
                  ),
                )
              else
                CachedNetworkImage(
                  imageUrl: currency.flagUrl,
                  width: 24,
                  height: 24,
                  placeholder: (context, url) => Container(
                    width: 24,
                    height: 24,
                    color: Colors.grey[200],
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 24,
                    height: 24,
                    color: Colors.grey[200],
                    child: const Icon(Icons.flag, size: 20),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                currency.code,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
