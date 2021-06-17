@TestOn('dart-vm')
import 'package:php_serializer/dart_vm_only/serialization_information_handler.dart';
import 'package:test/test.dart';

import 'package:php_serializer/php_serializer.dart';
import 'testClasses.dart';

void main() {
  test('Serialize class with automatic property mapping', () {
    expect(
        phpSerialize(
            ClassWithParameters(
                Parameter1: 42,
                otherParameter: 'Value',
                innerClass: DummyClass()),
            [],
            UsePropertiesOnMissingSerializationInformation()),
        'O:19:"ClassWithParameters":3:{s:10:"Parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}}');
  });
  test('Serialize class with automatic property mapping - including getters',
      () {
    expect(
        phpSerialize(
            ClassWithParameters(
                Parameter1: 42,
                otherParameter: 'Value',
                innerClass: DummyClass()),
            [],
            UsePropertiesOnMissingSerializationInformation(
                inspectGetters: true)),
        'O:19:"ClassWithParameters":4:{s:10:"Parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}s:18:"parameterViaGetter";i:42;}');
  });
  test(
      'Serialize class with automatic property mapping - including private properties',
      () {
    expect(
        phpSerialize(
            ClassWithParameters(
                Parameter1: 42,
                otherParameter: 'Value',
                innerClass: DummyClass()),
            [],
            UsePropertiesOnMissingSerializationInformation(
                inspectPrivate: true)),
        'O:19:"ClassWithParameters":4:{s:10:"Parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}s:16:"_hiddenDuplicate";s:5:"Value";}');
  });
}
