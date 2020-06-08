import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isotope/src/formatters/number_input_formatter.dart';

/// An implementation of [NumberInputFormatter] automatically inserts thousands
/// separators to numeric input. For example, a input of `1234` should be
/// formatted to `1,234`.
class ThousandsNumberInputFormatter extends NumberInputFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern();

  final WhitelistingTextInputFormatter _decimalFormatter;
  final String _decimalSeparator;
  final RegExp _decimalRegex;

  final NumberFormat formatter;
  final bool allowFraction;

  ThousandsNumberInputFormatter({this.formatter, this.allowFraction = false})
      : _decimalSeparator = (formatter ?? _formatter).symbols.DECIMAL_SEP,
        _decimalRegex = RegExp(allowFraction
            ? '[0-9]+([${(formatter ?? _formatter).symbols.DECIMAL_SEP}])?'
            : r'\d+'),
        _decimalFormatter = WhitelistingTextInputFormatter(RegExp(allowFraction
            ? '[0-9]+([${(formatter ?? _formatter).symbols.DECIMAL_SEP}])?'
            : r'\d+'));

  @override
  String formatPattern(String digits) {
    if (digits == null || digits.isEmpty) return digits;
    final number = allowFraction
        ? double.tryParse(digits) ?? 0.0
        : int.tryParse(digits) ?? 0;
    final result = (formatter ?? _formatter).format(number);
    if (allowFraction && digits.endsWith(_decimalSeparator)) {
      return '$result$_decimalSeparator';
    }
    return result;
  }

  @override
  TextEditingValue formatValue(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return _decimalFormatter.formatEditUpdate(oldValue, newValue);
  }

  @override
  bool isUserInput(String s) {
    return s == _decimalSeparator || _decimalRegex.firstMatch(s) != null;
  }
}
