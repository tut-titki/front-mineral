import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/auth/phone_input_formatter.dart';

TextEditingValue editing(String text, [int? caret]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: caret ?? text.length),
);

void main() {
  const formatter = PhoneInputFormatter();

  test('formats national numbers and pasted country prefixes', () {
    for (final input in ['7001234567', '+77001234567', '87001234567']) {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        editing(input),
      );
      expect(result.text, '+7 700 123 45 67');
      expect(result.selection.extentOffset, result.text.length);
      expect(validatePhone(result.text), isNull);
    }
  });

  test('limits length and rejects incomplete numbers', () {
    expect(
      formatter
          .formatEditUpdate(TextEditingValue.empty, editing('700123456799'))
          .text,
      '+7 700 123 45 67',
    );
    expect(validatePhone('+7 700'), isNotNull);
    expect(validatePhone(''), isNotNull);
  });

  test('backspace over a separator removes preceding digit', () {
    final result = formatter.formatEditUpdate(
      editing('+7 700 1', 7),
      editing('+7 7001', 6),
    );
    expect(result.text, '+7 701');
    expect(result.selection.extentOffset, 5);
  });

  test('preserves cursor on insertion in the middle', () {
    final result = formatter.formatEditUpdate(
      editing('+7 700 123', 4),
      editing('+7 7900 123', 5),
    );
    expect(result.text, '+7 790 012 3');
    expect(result.selection.extentOffset, 5);
  });

  test('allows clearing the field', () {
    expect(formatter.formatEditUpdate(editing('+7 7'), editing('')).text, '');
  });
}
