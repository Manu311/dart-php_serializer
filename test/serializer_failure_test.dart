import 'package:test/test.dart';

import 'package:php_serializer/php_serializer.dart';
import 'test_classes.dart';

void main() {
  test('Fail to serialize unknown object', () {
    expect(
        () => phpSerialize(const DummyClass()),
        throwsA(
            const TypeMatcher<ObjectWithoutSerializationInformationFound>()));
  });

  test('Fail to serialize object with error-throwing serialization-function',
      () {
    final thrownInnerException = Exception('Test me');
    expect(
        () => phpSerialize(const DummyClass(), knownClasses: [
              PhpSerializationObjectInformation<DummyClass>('DummyClass',
                  dataExtractor: (Object instance) =>
                      throw thrownInnerException)
            ]),
        throwsA((exception) =>
            (exception is CustomSerializationFailed) &&
            (thrownInnerException == exception.innerException)));
  });
}
