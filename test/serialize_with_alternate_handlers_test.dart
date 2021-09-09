@TestOn('dart-vm')
import 'package:php_serializer/dart_vm_only/serialization_information_handler.dart';
import 'package:test/test.dart';

import 'package:php_serializer/php_serializer.dart';
import 'test_classes.dart';

void main() {
  test('Serialize class with automatic property mapping', () {
    expect(
        phpSerialize(
            const ClassWithParameters(
                parameter1: 42,
                otherParameter: 'Value',
                innerClass: DummyClass()),
            fallbackObjectSerialization:
                const UsePropertiesOnMissingSerializationInformation()),
        'O:19:"ClassWithParameters":3:{s:10:"parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}}');
  });
  test('Serialize class with automatic property mapping - including getters',
      () {
    expect(
        phpSerialize(
            const ClassWithParameters(
                parameter1: 42,
                otherParameter: 'Value',
                innerClass: DummyClass()),
            fallbackObjectSerialization:
                const UsePropertiesOnMissingSerializationInformation(
                    inspectGetters: true)),
        'O:19:"ClassWithParameters":5:{s:10:"parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":1:{s:8:"hashCode";i:1;}s:18:"parameterViaGetter";i:42;s:8:"hashCode";i:46;}');
  });
  test(
      'Serialize class with automatic property mapping - including private properties',
      () {
    expect(
        phpSerialize(
            const ClassWithParameters(
                parameter1: 42,
                otherParameter: 'Value',
                innerClass: DummyClass()),
            fallbackObjectSerialization:
                const UsePropertiesOnMissingSerializationInformation(
                    inspectPrivate: true)),
        'O:19:"ClassWithParameters":4:{s:10:"parameter1";i:42;s:14:"otherParameter";s:5:"Value";s:10:"innerClass";O:10:"DummyClass":0:{}s:16:"_hiddenDuplicate";s:5:"Value";}');
  });
}
