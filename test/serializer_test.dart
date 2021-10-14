import 'package:test/test.dart';

import 'package:php_serializer/php_serializer.dart';
import 'test_classes.dart';

void main() {
  test('Serialize strings', () {
    expect(phpSerialize(''), 's:0:"";');
    expect(
        phpSerialize('This is a test String'), 's:21:"This is a test String";');
  });
  test('Serialize integers', () {
    expect(phpSerialize(42), 'i:42;');
    expect(phpSerialize(-42), 'i:-42;');
  });
  test('Serialize floating point numbers', () {
    expect(phpSerialize(53.06125), 'd:53.06125;');
    expect(phpSerialize(15.0100), 'd:15.01;');
  });
  test('Serialize Lists', () {
    expect(phpSerialize([1, 42, -100]), 'a:3:{i:0;i:1;i:1;i:42;i:2;i:-100;}');
    expect(
        phpSerialize([3, -5, 0, 9]), 'a:4:{i:0;i:3;i:1;i:-5;i:2;i:0;i:3;i:9;}');
    expect(phpSerialize([3, 'Php Serialized']),
        'a:2:{i:0;i:3;i:1;s:14:"Php Serialized";}');
  });
  test('Serialize Maps', () {
    expect(phpSerialize({'a': 42, 'Test me': 5, 5: 'Don\'t forget me'}),
        'a:3:{s:1:"a";i:42;s:7:"Test me";i:5;i:5;s:15:"Don\'t forget me";}');
  });

  test('Serialization of classes', () {
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
        phpSerialize(const DummyClass(), knownClasses: objectSerializationData),
        'O:10:"DummyClass":0:{}');
    expect(
        phpSerialize(
            const ClassWithParameters(
                parameter1: 42,
                otherParameter: 'Value',
                innerClass: DummyClass()),
            knownClasses: objectSerializationData), (String serializedString) {
      //Order of parameters can vary, so the test has to be flexible about it
      //Example output string:
      //'O:14:"ParameterClass":3:{s:10:"Parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}}'
      if (serializedString.substring(0, 25) != 'O:14:"ParameterClass":3:{' ||
          !serializedString.contains('s:10:"Parameter1";i:42;') ||
          !serializedString.contains('s:14:"otherParameter";s:5:"Value";') ||
          !serializedString
              .contains('s:10:"innerClass";O:10:"DummyClass":0:{}') ||
          serializedString.length != 123) return false;
      return true;
    });
  });
  test('Serialize closure/function', () {
    //Php doesn't allow closures to be serialized, but since everything is an
    //object in Dart, serialization of Closures is not a problem.
    serializeMe() => true;
    expect(
        phpSerialize(serializeMe, knownClasses: [
          PhpSerializationObjectInformation<bool Function()>(
              'ClosureReturningBool',
              dataExtractor: (Object object) => {})
        ]),
        'O:20:"ClosureReturningBool":0:{}');
  });
  test('Serialize null', () {
    expect(phpSerialize(null), 'N;');
  });
  test('Serialize bools', () {
    expect(phpSerialize(false), 'b:0;');
    expect(phpSerialize(true), 'b:1;');
  });
  test('Serialize umlauts', () {
    expect(phpSerialize('Hellö'), 's:6:"Hellö";');
  });
  test('Serialize emojis', () {
    expect(phpSerialize(String.fromCharCode(0x1f648)),
        's:4:"' + String.fromCharCode(0x1f648) + '";');
  });
}
