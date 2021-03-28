import 'package:php_serializer/deserializer.dart';
import 'package:php_serializer/php_serializer.dart';
import 'package:test/test.dart';

import 'testClasses.dart';

void main() {
  test('Fail to deserialize unknown object', () {
    expect(() => phpDeserialize('O:10:"DummyClass":0:{}'),
        throwsA(TypeMatcher<ObjectWithoutDeserializationInformationFound>()));
  });

  test('Fail to serialize object with error-throwing serialization-function',
      () {
    final thrownInnerException = Exception('Test me');
    expect(
        () => phpDeserialize('O:10:"DummyClass":0:{}', [
              PhpSerializationObjectInformation<DummyClass>(
                  'DummyClass',
                  (Map<String, dynamic> map) => throw thrownInnerException,
                  (Object instance) => <String, dynamic>{})
            ]),
        throwsA((exception) =>
            (exception is CustomDeserializationFailed) &&
            (thrownInnerException == exception.innerException)));
  });
}
