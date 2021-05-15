///Converts Php-Serialized objects into Dart and vice versa
library php_serializer;

export 'src/serializer.dart';
export 'src/deserializer.dart';

export 'src/missing_information_handler/missing_serialization_information_handler.dart';
export 'src/missing_information_handler/missing_deserialization_information_handler.dart';

/// Contains information about complex objects which can be (de-)serialized
///
/// A [List] of these can be passed to [phpSerialize] and [phpDeserialize]
class PhpSerializationObjectInformation<T extends Object> {
  ///Full Qualified Class Name (FQCN) that has to be used in Php to identify
  ///the class of the serialized object.
  final String serializedClassName;

  ///Function which receives a [Map] of all the serialized properties and
  ///generates the resulting object in Dart.
  final T Function(Map<String, dynamic> map) objectGenerator;

  //Object could be replaced with T, but generics inside of lambda-functions
  //do not work (yet)
  ///Function which receives an instance of an object and generates a [Map]
  ///which contains all the properties of the Php-object.
  final Map<String, dynamic> Function(Object instance) dataExtractor;

  Type get typeOf => T;

  PhpSerializationObjectInformation(
      this.serializedClassName, this.objectGenerator, this.dataExtractor);
}
