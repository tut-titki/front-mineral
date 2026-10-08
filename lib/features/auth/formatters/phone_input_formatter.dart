import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) {
      final limit = newValue.text.trimLeft().startsWith('+7') ? 11 : 10;
      return newValue.text.replaceAll(RegExp(r'\D'), '').length > limit
          ? oldValue
          : newValue;
    }

    var text = newValue.text;
    var caret = newValue.selection.isValid
        ? newValue.selection.extentOffset
        : text.length;

    // Backspace over a separator also removes the preceding digit.
    if (text.length < oldValue.text.length &&
        oldValue.selection.isCollapsed &&
        newValue.selection.isCollapsed &&
        text.replaceAll(RegExp(r'\D'), '') ==
            oldValue.text.replaceAll(RegExp(r'\D'), '')) {
      var index = caret - 1;
      while (index >= 0 && !RegExp(r'\d').hasMatch(text[index])) {
        index--;
      }
      if (index >= 2) {
        text = text.replaceRange(index, index + 1, '');
        caret = index;
      }
    }

    var digits = text.replaceAll(RegExp(r'\D'), '');
    var digitsBeforeCaret = text
        .substring(0, caret.clamp(0, text.length))
        .replaceAll(RegExp(r'\D'), '')
        .length;
    if ((text.startsWith('+7') && digits.startsWith('7')) ||
        (digits.length == 11 &&
            (digits.startsWith('7') || digits.startsWith('8')))) {
      digits = digits.substring(1);
      digitsBeforeCaret = (digitsBeforeCaret - 1).clamp(0, 10);
    }
    if (digits.length > 10 && validatePhone(oldValue.text) == null) {
      return oldValue;
    }
    if (digits.isEmpty) return TextEditingValue.empty;
    digits = digits.substring(0, digits.length.clamp(0, 10));

    final buffer = StringBuffer('+7 ');
    var selectionOffset = buffer.length;
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6 || i == 8) buffer.write(' ');
      buffer.write(digits[i]);
      if (i < digitsBeforeCaret) selectionOffset = buffer.length;
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}

String? validatePhone(
  String? value, {
  String emptyMessage = 'Введите номер телефона',
  String incompleteMessage = 'Введите номер полностью',
}) {
  if (value == null || value.trim().isEmpty) {
    return emptyMessage;
  }
  if (!RegExp(r'^\+7 \d{3} \d{3} \d{2} \d{2}$').hasMatch(value)) {
    return incompleteMessage;
  }
  return null;
}

/// National mask allows 11 digits; international numbers allow up to 15.
class ApiPhoneInputFormatter extends TextInputFormatter {
  const ApiPhoneInputFormatter();
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trimLeft();
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (text.startsWith('+') && !text.startsWith('+7')) {
      if (digits.length <= 15) return newValue;
      if (!newValue.composing.isCollapsed) return oldValue;
      var count = 0;
      var end = 0;
      for (; end < newValue.text.length; end++) {
        if (RegExp(r'\d').hasMatch(newValue.text[end]) && ++count > 15) break;
      }
      return TextEditingValue(
        text: newValue.text.substring(0, end),
        selection: TextSelection.collapsed(
          offset: newValue.selection.isValid
              ? newValue.selection.extentOffset.clamp(0, end)
              : end,
        ),
      );
    }
    return const PhoneInputFormatter().formatEditUpdate(oldValue, newValue);
  }
}
