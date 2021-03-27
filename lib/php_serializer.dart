library php_serializer;

import 'package:php_serializer/deserialize.dart';
import 'package:php_serializer/serializer.dart';

class PhpSerializer {
  /// Converts a string, which has been serialized by Php, into matching Objects
  static dynamic deserialize(String serializedString,
      [List<PhpSerializationObjectInformation>? knownClasses = null]) {
    return Deserializer.parse(serializedString, knownClasses ?? []);
  }

  /// Converts Objects of any type into a String which can be de-serialized by Php
  static String serialize(dynamic serializeMe,
      [List<PhpSerializationObjectInformation>? knownClasses = null]) {
    return Serializer.parse(serializeMe, knownClasses ?? []);
  }
}

class InvalidSerializedString extends FormatException {
  InvalidSerializedString(String serializedString) : super(serializedString);
}

abstract class PhpSerializableClass {
  Map<String, dynamic> get serializedMapForPhp;

  static String get uniqueNameForPhpSerialization => throw UnimplementedError();

  factory PhpSerializableClass.createFromPhpSerialization(
          String phpSerialized) =>
      throw UnimplementedError();
}


class PhpSerializationObjectInformation<T extends Object> {
  final String serializedClassName;
  final Object Function(Map<String, dynamic> map) objectGenerator;
  final Map<String, dynamic> Function(Object instance) dataExtractor;
  Type get typeOf => T;
  
  PhpSerializationObjectInformation(this.serializedClassName, this.objectGenerator, this.dataExtractor);
}