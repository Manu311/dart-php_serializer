import 'package:php_serializer/php_serializer.dart';
import 'package:test/test.dart';

final dateTimeConversion = PhpSerializationObjectInformation<DateTime>(
  'DateTime',
  dataExtractor: (dateTime) => {
    'date': (dateTime as DateTime).toString(),
    'timezone_type': 3,
    'timezone': 'UTC',
  },
  objectGenerator: (map) => DateTime.parse(map['date']),
);

void main() {
  test('Read php \\DateTime instance into dart DateTime class', () {
    final inputString =
        'O:8:"DateTime":3:{s:4:"date";s:26:"2022-01-09 15:18:18.015520";s:13:"timezone_type";i:3;s:8:"timezone";s:3:"UTC";}';
    expect(phpDeserialize(inputString, knownClasses: [dateTimeConversion]),
        DateTime(2022, 1, 9, 15, 18, 18, 015, 520));
  });

  test('Convert dart DateTime instance to php \\DateTime class', () {
    final dateTime = DateTime(2022, 1, 9, 15, 18, 18, 015, 520);
    expect(phpSerialize(dateTime, knownClasses: [dateTimeConversion]),
        'O:8:"DateTime":3:{s:4:"date";s:26:"2022-01-09 15:18:18.015520";s:13:"timezone_type";i:3;s:8:"timezone";s:3:"UTC";}');
  });
}
