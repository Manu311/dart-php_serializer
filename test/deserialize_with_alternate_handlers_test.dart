import 'package:php_serializer/php_serializer.dart';
import 'package:test/test.dart';

import 'testClasses.dart';

void main() {
  test('Deserialize classes into Maps', () {
    expect(
        phpDeserialize(
            'O:19:"ClassWithParameters":4:{s:10:"Parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}s:11:"innerClass2";O:11:"DummyClass2":0:{}}',
            knownClasses: [
              PhpSerializationObjectInformation<DummyClass>(
                  'DummyClass',
                  (Map<String, dynamic> map) => DummyClass(),
                  (Object instance) => <String, dynamic>{}),
            ],
            fallbackObjectDeserialization:
                GenerateMapOnMissingDeserializationInformation()),
        {
          'Parameter1': 42,
          'otherParameter': 'Value',
          'innerClass': DummyClass(),
          'innerClass2': {}
        });
  });

  test('Generate dart-code from types', () {
    expect(
        phpDeserialize(
            'O:19:"ClassWithParameters":4:{s:10:"Parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}s:11:"innerClass2";O:11:"DummyClass2":0:{}}',
            fallbackObjectDeserialization:
                GenerateDartClassCodeOnMissingDeserializationInformation()),
        '''
class ClassWithParameters {
  final int Parameter1;
  final String otherParameter;
  final DummyClass innerClass;
  final DummyClass2 innerClass2;

  const ClassWithParameters({
      required this.Parameter1,
      required this.otherParameter,
      required this.innerClass,
      required this.innerClass2
  });

  static final phpSerializationObjectInformation =
  PhpSerializationObjectInformation<ClassWithParameters>(
    'ClassWithParameters',
        (Map<String, dynamic> map) =>
        ClassWithParameters(
              Parameter1: map['Parameter1'],
              otherParameter: map['otherParameter'],
              innerClass: map['innerClass'],
              innerClass2: map['innerClass2']),
    (Object instance) =>
    <String, dynamic>{
        'Parameter1': instance.Parameter1,
        'otherParameter': instance.otherParameter,
        'innerClass': instance.innerClass,
        'innerClass2': instance.innerClass2
    });
}
''');

    expect(
        phpDeserialize(
            r'a:2:{i:0;O:3:"Foo":1:{s:3:"bar";O:3:"Bar":0:{}}i:1;O:3:"Bar":1:{s:3:"foo";O:3:"Foo":0:{}}}',
            fallbackObjectDeserialization:
                GenerateDartClassCodeOnMissingDeserializationInformation()),
        [
          '''class Foo {
  final Bar bar;

  const Foo({
      required this.bar
  });

  static final phpSerializationObjectInformation =
  PhpSerializationObjectInformation<Foo>(
    'Foo',
        (Map<String, dynamic> map) =>
        Foo(
              bar: map['bar']),
    (Object instance) =>
    <String, dynamic>{
        'bar': instance.bar
    });
}
''',
          '''
class Bar {
  final Foo foo;

  const Bar({
      required this.foo
  });

  static final phpSerializationObjectInformation =
  PhpSerializationObjectInformation<Bar>(
    'Bar',
        (Map<String, dynamic> map) =>
        Bar(
              foo: map['foo']),
    (Object instance) =>
    <String, dynamic>{
        'foo': instance.foo
    });
}
'''
        ]);
  });
}
