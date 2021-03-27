library php_serializer;

import 'package:php_serializer/serializer.dart';

class PhpSerializer {
  /// Converts a string, which has been serialized by Php, into matching Objects
  static dynamic deserialize(String serializedString) {
    throw InvalidSerializedString(serializedString);
  }

  /// Converts Objects of any type into a String which can be de-serialized by Php
  static String serialize(dynamic serializeMe) {
    return Serializer.parse(serializeMe);
  }
}

class InvalidSerializedString extends FormatException {
  final String serializedString;
  InvalidSerializedString(this.serializedString);
}

abstract class PhpSerializableClass {
  Map<String,dynamic> get serializedMapForPhp;
  String get uniqueNameForPhpSerialization;
  factory PhpSerializableClass.createFromPhpSerialization(String phpSerialized) {
    throw UnimplementedError();
  }
}
