import 'dart:convert';

import '../php_serializer.dart';

/// Takes an object and converts it into a [String] which could be deserialized
/// by Php via its function `unserialize()`.
///
/// Only fundamental Objects are recognized, every other object requires
/// additional information via a [List] of [PhpSerializationObjectInformation]
/// as the second argument.
/// Alternatively the third argument can be used to specify different behavior
/// in case there is no matching [PhpSerializationObjectInformation] for
/// classes.
String phpSerialize(dynamic serializeMe,
        {List<PhpSerializationObjectInformation>? knownClasses,
        NoMatchingObjectSerializationInformation?
            fallbackObjectSerialization}) =>
    _Serializer(
            knownClasses ?? [],
            fallbackObjectSerialization ??
                const ThrowExceptionOnMissingSerializationInformation())
        .parse(serializeMe);

/// Implement this interface to customize the action when there is not matching
/// information for serialization.
/// {@category Fallback Behavior}
abstract class NoMatchingObjectSerializationInformation {
  /// Return a [PhpSerializationObjectInformation] for the requested class
  PhpSerializationObjectInformation handleSerialization(Type objectType);
}

/// Will be thrown in case [phpSerialize] fails for some reason
abstract class SerializationException implements Exception {
  final String message;

  const SerializationException(this.message);

  @override
  String toString() => message;
}

///Serialization of an object failed because there was no matching
///[PhpSerializationObjectInformation] provided
class ObjectWithoutSerializationInformationFound
    implements SerializationException {
  final Type objectType;

  @override
  String get message =>
      'An object of type ${objectType.toString()} couldn\'t be serialized, since no serialization-information was provided!';

  const ObjectWithoutSerializationInformationFound(this.objectType);
}

///Serialization of an object failed because the user-defined converter
///function threw an exception.
class CustomSerializationFailed implements SerializationException {
  final dynamic innerException;
  final Type objectType;

  @override
  String get message =>
      'An exception of type ${innerException.runtimeType.toString()} was thrown when trying to serialize an Object of Type ${objectType.toString()}\n'
      'Inner ${innerException.toString()}';

  const CustomSerializationFailed(this.objectType, this.innerException);
}

class _Serializer {
  final List<PhpSerializationObjectInformation> _objectInformation;
  final NoMatchingObjectSerializationInformation _fallbackObjectSerialization;

  const _Serializer(this._objectInformation, this._fallbackObjectSerialization);

  String parse(dynamic rawInput) {
    switch (rawInput.runtimeType) {
      case String:
        return _parseString(rawInput);
      case int:
        return _parseInt(rawInput);
      case double:
        return _parseDouble(rawInput);
      case Null:
        return 'N;';
      case bool:
        return (rawInput) ? 'b:1;' : 'b:0;';
      default:
    }

    if (rawInput is List) {
      return _parseList(rawInput);
    }

    if (rawInput is Map) {
      return _parseMap(rawInput);
    }

    return _parseSerializableClass(rawInput);
  }

  String _parseString(String inputString) {
    return 's:${utf8.encode(inputString).length}:"$inputString";';
  }

  String _parseInt(int inputInt) {
    return 'i:$inputInt;';
  }

  String _parseDouble(double inputDouble) {
    if (inputDouble.floorToDouble() == inputDouble) {
      return 'd:${inputDouble.floor()};';
    }
    return 'd:$inputDouble;';
  }

  String _parseList(List<dynamic> inputList) {
    final sb = StringBuffer('a:${inputList.length}:{');
    for (var i = 0; i != inputList.length; ++i) {
      sb.write('i:$i;');
      sb.write(parse(inputList[i]));
    }

    sb.write('}');
    return sb.toString();
  }

  String _parseMap(Map<dynamic, dynamic> inputMap,
      {bool prependArrayIdentifierAndSize = true}) {
    final sb = StringBuffer();
    if (prependArrayIdentifierAndSize) sb.write('a:${inputMap.length}:');
    sb.write('{');

    inputMap.forEach((key, value) {
      sb.write('${parse(key)}${parse(value)}');
    });

    sb.write('}');
    return sb.toString();
  }

  String _parseSerializableClass(Object inputClass) {
    final matchingObject = _objectInformation.firstWhere(
        (element) => element.typeOf == inputClass.runtimeType,
        orElse: () => _fallbackObjectSerialization
            .handleSerialization(inputClass.runtimeType));
    final className = matchingObject.serializedClassName;
    late final Map<String, dynamic> intermediateMap;

    final dataExtractor = matchingObject.dataExtractor ??
        _fallbackObjectSerialization
            .handleSerialization(inputClass.runtimeType)
            .dataExtractor;

    if (dataExtractor == null) {
      throw ObjectWithoutSerializationInformationFound(inputClass.runtimeType);
    }

    try {
      intermediateMap = dataExtractor(inputClass);
    } catch (e) {
      throw CustomSerializationFailed(matchingObject.typeOf, e);
    }
    final serializedMap =
        _parseMap(intermediateMap, prependArrayIdentifierAndSize: false);
    return 'O:${className.length}:"$className":${intermediateMap.length}:$serializedMap';
  }
}
