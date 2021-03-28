library php_serializer;

export 'serializer.dart' show phpSerialize;
export 'deserialize.dart' show phpDeserialize;

class InvalidSerializedString extends FormatException {
  InvalidSerializedString(String serializedString) : super(serializedString);
}

class PhpSerializationObjectInformation<T extends Object> {
  final String serializedClassName;
  final Object Function(Map<String, dynamic> map) objectGenerator;
  final Map<String, dynamic> Function(Object instance) dataExtractor;

  Type get typeOf => T;

  PhpSerializationObjectInformation(
      this.serializedClassName, this.objectGenerator, this.dataExtractor);
}
