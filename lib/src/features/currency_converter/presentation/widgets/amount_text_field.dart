import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountTextField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final String? errorText;
  final TextStyle? amountStyle;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Key? textFieldKey;

  const AmountTextField({
    super.key,
    this.label,
    required this.controller,
    this.onChanged,
    this.readOnly = false,
    this.errorText,
    this.amountStyle,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.textFieldKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Text(
          label!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: textFieldKey,
          controller: controller,
          
          style: amountStyle ?? theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? '0.00',
          
            hintStyle: theme.textTheme.headlineSmall?.copyWith(
              color: theme.hintColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
             
            ),
            // enabledBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(12),
             
            // ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1F2261)
            
            ),),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
             
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            
            ),
            errorText: errorText,
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            isDense: true,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: inputFormatters ?? [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onChanged: onChanged,
          readOnly: readOnly,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
