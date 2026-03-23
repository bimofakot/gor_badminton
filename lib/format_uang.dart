import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;

    // Menghapus titik yang sudah ada agar bisa dihitung ulang
    String plainText = newValue.text.replaceAll('.', '');
    double value = double.parse(plainText);

    // Format ulang dengan titik ribuan (IDR)
    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}