import 'php_serializer.dart';

/// Takes an object and converts it into a [String] which could be deserialized
/// by Php via its function `deserialize()`.
///
/// Only fundamental Objects are recognized, every other object requires
/// additional information via a [List] of [PhpSerializationObjectInformation]
/// as the second argument.
String phpSerialize(dynamic serializeMe,
    [List<PhpSerializationObjectInformation>? knownClasses = null]) {
  return _Serializer.parse(serializeMe, knownClasses ?? []);
}

abstract class SerializationException implements Exception {
  final String message;

  SerializationException(this.message);

  @override
  String toString() => this.message;
}

///Serialization of an object failed because there was no matching
///[PhpSerializationObjectInformation] provided
class ObjectWithoutSerializationInformationFound
    extends SerializationException {
  ObjectWithoutSerializationInformationFound(Type objectType)
      : super(
      'An object of type ${objectType.toString()} couldn\'t be serialized, since no serialiazion-information was provided!');
}

///Serialization of an object failed because the user-defined converter
///function threw an exception.
class CustomSerializationFailed extends SerializationException {
  final dynamic innerException;

  CustomSerializationFailed(Type objectType, this.innerException)
      : super(
      'An exception of type ${innerException.runtimeType.toString()} was thrown when trying to serialize an Object of Type ${objectType.toString()}\n'
          'Inner ${innerException.toString()}');
}

class _Serializer {
  static String parse(dynamic rawInput,
      List<PhpSerializationObjectInformation> objectInformation) {
    switch (rawInput.runtimeType) {
      case String:
        return _parseString(rawInput);
      case int:
        return _parseInt(rawInput);
      case double:
        return _parseDouble(rawInput);
      default:
    }

    if (rawInput is List) {
      return _parseList(rawInput, objectInformation);
    }

    if (rawInput is Map) {
      return _parseMap(rawInput, objectInformation);
    }

    return _parseSerializableClass(rawInput, objectInformation);
  }

  static String _parseString(String inputString) {
    return 's:${inputString.length}:"${inputString}";';
  }

  static String _parseInt(int inputInt) {
    return 'i:${inputInt};';
  }

  static String _parseDouble(double inputDouble) {
    if (inputDouble.floorToDouble() == inputDouble)
      return 'd:${inputDouble.floor()};';
    return 'd:${inputDouble};';
  }

  static String _parseList(List<dynamic> inputList,
      List<PhpSerializationObjectInformation> objectInformation) {
    final sb = StringBuffer('a:${inputList.length}:{');
    for (var i = 0; i != inputList.length; ++i) {
      sb.write('i:${i};');
      sb.write(parse(inputList[i], objectInformation));
    }

    sb.write('}');
    return sb.toString();
  }

  static String _parseMap(Map<dynamic, dynamic> inputMap,
      List<PhpSerializationObjectInformation> objectInformation,
      {bool prependArrayIdentifierAndSize = true}) {
    final sb = StringBuffer();
    if (prependArrayIdentifierAndSize) sb.write('a:${inputMap.length}:');
    sb.write('{');

    inputMap.forEach((key, value) {
      sb.write(
          '${parse(key, objectInformation)}${parse(value, objectInformation)}');
    });

    sb.write('}');
    return sb.toString();
  }

  static String _parseSerializableClass(Object inputClass,
      List<PhpSerializationObjectInformation> objectInformation) {
    final matchingObject = objectInformation.firstWhere(
        (element) => element.typeOf == inputClass.runtimeType,
        orElse: () => throw ObjectWithoutSerializationInformationFound(
            inputClass.runtimeType));
    final className = matchingObject.serializedClassName;
    late final intermediateMap;
    try {
      intermediateMap = matchingObject.dataExtractor(inputClass);
    } catch (e) {
      throw CustomSerializationFailed(matchingObject.typeOf, e);
    }
    final serializer = _parseMap(intermediateMap, objectInformation,
        prependArrayIdentifierAndSize: false);
    return 'O:${className.length}:"${className}":${intermediateMap.length}:${serializer}';
  }
}
