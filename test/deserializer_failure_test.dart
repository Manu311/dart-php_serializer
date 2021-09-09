import 'package:test/test.dart';

import 'package:php_serializer/php_serializer.dart';
import 'test_classes.dart';

void main() {
  test('Fail to deserialize unknown object', () {
    expect(
        () => phpDeserialize('O:10:"DummyClass":0:{}'),
        throwsA(
            const TypeMatcher<ObjectWithoutDeserializationInformationFound>()));
  });

  test('Fail to serialize object with error-throwing serialization-function',
      () {
    final thrownInnerException = Exception('Test me');
    expect(
        () => phpDeserialize('O:10:"DummyClass":0:{}', knownClasses: [
              PhpSerializationObjectInformation<DummyClass>(
                'DummyClass',
                objectGenerator: (Map<String, dynamic> map) =>
                    throw thrownInnerException,
              )
            ]),
        throwsA((exception) =>
            (exception is CustomDeserializationFailed) &&
            (thrownInnerException == exception.innerException)));
  });
}
