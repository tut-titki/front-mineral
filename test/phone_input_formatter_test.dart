import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/auth/formatters/phone_input_formatter.dart';

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

  test('API mask blocks extra digits at the end and in the middle', () {
    const api = ApiPhoneInputFormatter();
    final full = editing('+7 700 123 45 67');
    expect(api.formatEditUpdate(full, editing('${full.text}8')), full);
    final middle = editing(full.text, 5);
    expect(
      api.formatEditUpdate(middle, editing('+7 7090 123 45 67', 6)),
      middle,
    );
    expect(
      api
          .formatEditUpdate(
            TextEditingValue.empty,
            editing('+7 700 123 45 67899'),
          )
          .text,
      full.text,
    );
  });

  test('a full number still permits deleting and replacing digits', () {
    const api = ApiPhoneInputFormatter();
    final full = editing('+7 700 123 45 67');
    expect(
      api.formatEditUpdate(full, editing('+7 700 123 45 6')).text,
      '+7 700 123 45 6',
    );
    expect(
      api.formatEditUpdate(full, editing('+7 700 123 45 68')).text,
      '+7 700 123 45 68',
    );
  });

  test('composition cannot exceed the national mask', () {
    const api = ApiPhoneInputFormatter();
    final full = editing('+7 700 123 45 67');
    final input = editing(
      '${full.text}8',
    ).copyWith(composing: const TextRange(start: 15, end: 16));
    expect(api.formatEditUpdate(full, input), full);
  });
}
