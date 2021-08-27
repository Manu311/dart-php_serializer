import '../../php_serializer.dart';

/// Throws an exception of type [SerializationException] if there is no
/// matching [PhpSerializationObjectInformation] for a class.
/// {@category Fallback Behavior}
class ThrowExceptionOnMissingSerializationInformation
    implements NoMatchingObjectSerializationInformation {
  const ThrowExceptionOnMissingSerializationInformation();

  @override
  PhpSerializationObjectInformation handleSerialization(Type objectType) {
    throw ObjectWithoutSerializationInformationFound(objectType);
  }
}
