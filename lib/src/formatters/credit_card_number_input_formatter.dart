import 'dart:math';
import 'package:flutter/services.dart';
import 'package:isotope/src/formatters/number_input_formatter.dart';

/// An implementation of [NumberInputFormatter] that converts a numeric input
/// to credit card number form (4-digit grouping). For example, a input of
/// `12345678` should be formatted to `1234 5678`.
class CreditCardNumberInputFormatter extends NumberInputFormatter {
  static final RegExp _digitOnlyRegex = RegExp(r'\d+');
  static final FilteringTextInputFormatter _digitOnlyFormatter =
      FilteringTextInputFormatter(_digitOnlyRegex, allow: true);

  final String separator;

  CreditCardNumberInputFormatter({this.separator = ' '});

  @override
  String formatPattern(String digits) {
    StringBuffer buffer = StringBuffer();
    int offset = 0;
    int count = min(4, digits.length);

    final length = digits.length;

    for (; count <= length; count += min(4, max(1, length - count))) {
      buffer.write(digits.substring(offset, count));

      if (count < length) {
        buffer.write(separator);
      }

      offset = count;
    }

    return buffer.toString();
  }

  @override
  TextEditingValue formatValue(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return _digitOnlyFormatter.formatEditUpdate(oldValue, newValue);
  }

  @override
  bool isUserInput(String s) {
    return _digitOnlyRegex.firstMatch(s) != null;
  }
}
