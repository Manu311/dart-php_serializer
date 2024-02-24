import 'package:test/test.dart';

import 'package:php_serializer/php_serializer.dart';
import 'test_classes.dart';

void main() {
  test('Serialize strings', () {
    expect(phpDeserialize('s:0:"";'), '');
    expect(phpDeserialize('s:21:"This is a test String";'),
        'This is a test String');
  });
  test('Deserialize integers', () {
    expect(phpDeserialize('i:42;'), 42);
    expect(phpDeserialize('i:-42;'), -42);
  });
  test('Serialize floating point numbers', () {
    expect(phpDeserialize('d:53.06125;'), 53.06125);
    expect(phpDeserialize('d:15;'), 15.0);
  });
  test('Deserialize Lists', () {
    expect(phpDeserialize('a:3:{i:0;i:1;i:1;i:42;i:2;i:-100;}'), [1, 42, -100]);
    expect(phpDeserialize('a:4:{i:0;i:3;i:1;i:-5;i:2;i:0;i:3;i:9;}'),
        [3, -5, 0, 9]);
    expect(phpDeserialize('a:2:{i:0;i:3;i:1;s:16:"Php deserialized";}'),
        [3, 'Php deserialized']);
  });
  test('Deserialize Maps', () {
    expect(
        phpDeserialize(
            'a:3:{s:1:"a";i:42;s:7:"Test me";i:5;i:5;s:15:"Don\'t forget me";}'),
        {'a': 42, 'Test me': 5, 5: 'Don\'t forget me'});
  });

  test('Deserialization of classes', () {
    final objectSerializationData = [
      PhpSerializationObjectInformation<DummyClass>('DummyClass',
          objectGenerator: (Map<String, dynamic> map) => const DummyClass(),
          dataExtractor: (Object instance) => <String, dynamic>{}),
      PhpSerializationObjectInformation<ClassWithParameters>('ParameterClass',
          objectGenerator: (Map<String, dynamic> map) => ClassWithParameters(
              parameter1: map['Parameter1'],
              innerClass: map['innerClass'],
              otherParameter: map['otherParameter']),
          dataExtractor: (Object instance) => {
                'Parameter1': (instance as ClassWithParameters).parameter1,
                'innerClass': instance.innerClass,
                'otherParameter': instance.otherParameter
              })
    ];
    expect(
        phpDeserialize('O:10:"DummyClass":0:{}',
            knownClasses: objectSerializationData),
        const DummyClass());
    expect(
        phpDeserialize(
            'O:14:"ParameterClass":3:{s:10:"Parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}}',
            knownClasses: objectSerializationData),
        const ClassWithParameters(
            parameter1: 42, otherParameter: 'Value', innerClass: DummyClass()));
  });
  test('Deserialize null', () {
    expect(phpDeserialize('N;'), null);
  });
  test('Serialize bools', () {
    expect(phpDeserialize('b:0;'), false);
    expect(phpDeserialize('b:1;'), true);
  });
  test('Deserialize umlauts', () {
    expect(phpDeserialize('s:6:"Hellö";'), 'Hellö');
  });
  test('Deserialize emojis', () {
    expect(phpDeserialize('s:4:"${String.fromCharCode(0x1f648)}";'),
        String.fromCharCode(0x1f648));
  });
  test('Deserialize special characters', () {
    expect(phpDeserialize('a:1:{s:4:"acre";s:29:"50’x70’x80’ how are you";}'),
        {'acre': '50’x70’x80’ how are you'});
  });
  test('Deserialize scientific notation', () {
    expect(phpDeserialize('d:-42e200;'), -42e200);
    expect(phpDeserialize('d:42E-20;'), 42e-20);
  });
  test('Deserialize NaN', () {
    expect(phpDeserialize('d:NAN;'), isNaN);
  });
}
