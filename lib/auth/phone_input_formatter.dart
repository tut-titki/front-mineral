import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;

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
