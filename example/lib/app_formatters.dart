import 'package:flutter/services.dart';

class MacAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Remove all non-hexadecimal characters
    String filteredValue = newValue.text.replaceAll(RegExp(r'[^a-fA-F0-9]'), '');

    // Insert colons after every two characters
    String formattedValue = '';
    for (int i = 0; i < filteredValue.length; i++) {
      if (i > 0 && i % 2 == 0) {
        formattedValue += ':';
      }
      formattedValue += filteredValue[i];
    }

    // Restrict to a maximum of 17 characters (e.g., "00:11:22:33:44:55")
    if (formattedValue.length > 17) {
      formattedValue = formattedValue.substring(0, 17);
    }

    // Preserve cursor position
    int selectionIndex = formattedValue.length;
    if (formattedValue.endsWith(':') && oldValue.text.length > newValue.text.length) {
      selectionIndex--;
    }

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class UppercaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}