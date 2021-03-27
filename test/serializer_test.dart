import 'package:test/test.dart';

import 'package:php_serializer/php_serializer.dart';
import 'testClasses.dart';

void main() {
  const serialize = PhpSerializer.serialize;
  test('Serialize strings', () {
    expect(serialize(''), 's:0:"";');
    expect(serialize('This is a test String'), 's:21:"This is a test String";');
  });
  test('Serialize integers', () {
    expect(serialize(42), 'i:42;');
    expect(serialize(-42), 'i:-42;');
  });
  test('Serialize Lists', () {
    expect(serialize([1, 42, -100]), 'a:3:{i:0;i:1;i:1;i:42;i:2;i:-100;}');
    expect(serialize([3, -5, 0, 9]), 'a:4:{i:0;i:3;i:1;i:-5;i:2;i:0;i:3;i:9;}');
    expect(serialize([3, 'Php Serialized']),
        'a:2:{i:0;i:3;i:1;s:14:"Php Serialized";}');
  });
  test('Serialize Maps', () {
    expect(serialize({'a': 42, 'Test me': 5, 5: 'Don\'t forget me'}),
        'a:3:{s:1:"a";i:42;s:7:"Test me";i:5;i:5;s:15:"Don\'t forget me";}');
  });

  test('Serialization of classes', () {
    final objectSerializationData = [
      PhpSerializationObjectInformation<DummyClass>(
          'DummyClass',
          (Map<String, dynamic> map) => DummyClass(),
          (Object instance) => Map<String, dynamic>()),
      PhpSerializationObjectInformation<ClassWithParameters>(
          'ParameterClass',
          (Map<String, dynamic> map) => ClassWithParameters(
              Parameter1: map['Parameter1'],
              innerClass: map['innerClass'],
              otherParameter: map['otherParameter']),
          (Object instance) => {
                'Parameter1': (instance as ClassWithParameters).Parameter1,
                'innerClass': instance.innerClass,
                'otherParameter': instance.otherParameter
              })
    ];
    expect(serialize(DummyClass(), objectSerializationData),
        'O:10:"DummyClass":0:{}');
    expect(
        serialize(
            ClassWithParameters(
                Parameter1: 42,
                otherParameter: 'Value',
                innerClass: DummyClass()),
            objectSerializationData), (String serializedString) {
      //Order of parameters can vary, so the test has to be flexible about it
      //Example output string:
      //'O:14:"ParameterClass":3:{s:10:"Parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}}'
      if (serializedString.substring(0, 25) != 'O:14:"ParameterClass":3:{' ||
          serializedString.indexOf('s:10:"Parameter1";i:42;') == -1 ||
          serializedString.indexOf('s:14:"otherParameter";s:5:"Value";') ==
              -1 ||
          serializedString
                  .indexOf('s:10:"innerClass";O:10:"DummyClass":0:{}') ==
              -1 ||
          serializedString.length != 123) return false;
      return true;
    });
  });
}
