import 'package:test/test.dart';

import 'package:php_serializer/php_serializer.dart';
import 'testClasses.dart';

void main() {
  test('Fail to serialize unknown object', () {
    expect(() => phpSerialize(DummyClass()),
        throwsA(TypeMatcher<ObjectWithoutSerializationInformationFound>()));
  });

  test('Fail to serialize object with error-throwing serialization-function',
      () {
    final thrownInnerException = Exception('Test me');
    expect(
        () => phpSerialize(DummyClass(), [
              PhpSerializationObjectInformation<DummyClass>(
                  'DummyClass',
                  (Map<String, dynamic> map) => DummyClass(),
                  (Object instance) => throw thrownInnerException)
            ]),
        throwsA((exception) =>
            (exception is CustomSerializationFailed) &&
            (thrownInnerException == exception.innerException)));
  });
}
