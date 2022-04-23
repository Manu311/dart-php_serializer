import 'dart:convert';

import '../php_serializer.dart';

/// Parses a [String] which could be provided by Php via its function
/// `serialize()` and returns the resulting object.
///
/// If more complex objects should be deserialized, further details for those
/// have to be provided via a [List] of [PhpSerializationObjectInformation]
/// as the second argument.
dynamic phpDeserialize(String serializedString,
        {List<PhpSerializationObjectInformation>? knownClasses,
        NoMatchingObjectDeserializationInformation?
            fallbackObjectDeserialization}) =>
    _Deserializer(
            knownClasses ?? [],
            fallbackObjectDeserialization ??
                const ThrowExceptionOnMissingDeserializationInformation())
        .parse(serializedString);

/// Implement this interface to customize the action when there is not matching
/// information for deserialization.
/// {@category Fallback Behavior}
abstract class NoMatchingObjectDeserializationInformation {
  /// Return a [PhpSerializationObjectInformation] for the class identified by
  /// [classIdentifier]
  PhpSerializationObjectInformation handleDeserialization(
      String classIdentifier);
}

/// Will be thrown in case [phpDeserialize] fails for some reason
abstract class DeserializationException implements Exception {
  final String message;

  const DeserializationException(this.message);

  @override
  String toString() => message;
}

///Deserialization of an object failed because there was no matching
///[PhpSerializationObjectInformation] provided
class ObjectWithoutDeserializationInformationFound
    extends DeserializationException {
  const ObjectWithoutDeserializationInformationFound(String fqcn)
      : super(
            'An object with classname $fqcn couldn\'t be deserialized, since no deserialiazion-information was provided!');
}

///Deserialization of an object failed because the user-defined converter
///function threw an exception.
class CustomDeserializationFailed implements DeserializationException {
  final dynamic innerException;
  final Type objectType;

  @override
  String get message =>
      'An exception of type ${innerException.runtimeType.toString()} was thrown when trying to deserialize an Object of Type ${objectType.toString()}\n'
      'Inner ${innerException.toString()}';

  const CustomDeserializationFailed(this.objectType, this.innerException);
}

///Deserialization failed because the passed string was invalid
class InvalidSerializedString extends DeserializationException {
  const InvalidSerializedString(String serializedString)
      : super('Invalid serialized string: $serializedString');
}

class _Deserializer {
  final List<PhpSerializationObjectInformation> knownClasses;
  final NoMatchingObjectDeserializationInformation
      fallbackObjectDeserialization;

  const _Deserializer(this.knownClasses, this.fallbackObjectDeserialization);

  dynamic parse(String rawInput) {
    final repr = _StringRepresentation(
        rawInput, knownClasses, fallbackObjectDeserialization);
    return _parse(repr);
  }

  static const smallS = 115; //s
  static const smallI = 105; //i
  static const smallD = 100; //d
  static const smallA = 97; //a
  static const bigO = 79; //O
  static const bigN = 78; //N
  static const smallB = 98; //b
  static const digitOne = 49; //1
  static const charColon = 58; //:
  static const charSemicolon = 59; //:

  dynamic _parse(_StringRepresentation repr) {
    switch (repr.readSingleCodeUnitAndSkipOne()) {
      case smallS:
        return _parseString(repr);
      case smallI:
        return _parseInt(repr);
      case smallD:
        return _parseDouble(repr);
      case smallA:
        return _parseArray(repr);
      case bigO:
        return _parseObject(repr);
      case bigN:
        return null;
      case smallB:
        return (repr.readSingleCodeUnitAndSkipOne() == digitOne);
      default:
        throw InvalidSerializedString(repr.readAll(100));
    }
  }

  String _parseString(_StringRepresentation repr) {
    final lengthOfString =
        int.parse(repr.readUntil(delimiter: charColon, skip: 2));
    final returnValue = repr.read(lengthOfString, skip: 2);
    return returnValue;
  }

  int _parseInt(_StringRepresentation repr) {
    final returnValue = repr.readUntil(delimiter: charSemicolon, skip: 1);
    return int.parse(returnValue);
  }

  double _parseDouble(_StringRepresentation repr) {
    final returnValue = repr.readUntil(delimiter: charSemicolon, skip: 1);
    return double.parse(returnValue);
  }

  dynamic _parseArray(_StringRepresentation repr,
      {bool allowSimplification = true}) {
    final arrayLength =
        int.parse(repr.readUntil(delimiter: charColon, skip: 2));
    final possibleReturnValue = <dynamic, dynamic>{};
    var canBeSimplified = allowSimplification;

    for (var i = 0; i != arrayLength; ++i) {
      final key = _parse(repr);
      if (canBeSimplified && (key is! int || key != i)) {
        canBeSimplified = false;
      }
      final value = _parse(repr);
      possibleReturnValue[key] = value;
    }
    repr.skip();

    if (canBeSimplified) {
      return List<dynamic>.generate(
          possibleReturnValue.length, (index) => possibleReturnValue[index]);
    }

    return possibleReturnValue;
  }

  dynamic _parseObject(_StringRepresentation repr) {
    final lengthOfName =
        int.parse(repr.readUntil(delimiter: charColon, skip: 2));
    final classIdentifier = repr.read(lengthOfName, skip: 2);
    final parameterArray = Map<String, dynamic>.from(
        _parseArray(repr, allowSimplification: false));
    final objectInfo = repr.getObjectInformation(classIdentifier);
    final objectGenerator = (objectInfo.objectGenerator ??
        fallbackObjectDeserialization
            .handleDeserialization(classIdentifier)
            .objectGenerator);

    if (objectGenerator == null) {
      throw ObjectWithoutDeserializationInformationFound(classIdentifier);
    }

    try {
      return objectGenerator(parameterArray);
    } catch (e) {
      throw CustomDeserializationFailed(objectInfo.typeOf, e);
    }
  }
}

class _StringRepresentation {
  final List<int> _utf8Chars;
  int _offset = 0;

  final List<PhpSerializationObjectInformation> _knownClasses;
  final NoMatchingObjectDeserializationInformation
      fallbackObjectDeserialization;

  _StringRepresentation(
      String rawString, this._knownClasses, this.fallbackObjectDeserialization)
      : _utf8Chars = utf8.encode(rawString);

  void skip([int length = 1]) {
    _offset += length;
  }

  int readSingleCodeUnitAndSkipOne() {
    _offset += 2;
    return _utf8Chars.elementAt(_offset - 2);
  }

  String read(int length, {int skip = 0}) {
    if (length > remaining) length = remaining;

    var returnValue =
        utf8.decode(_utf8Chars.sublist(_offset, _offset + length));
    _offset += length + skip;
    return returnValue;
  }

  String readUntil({required int delimiter, int skip = 0}) {
    int i;
    for (i = _offset;
        _utf8Chars[i] != delimiter || i >= _utf8Chars.length;
        ++i) {}

    return read(i - _offset, skip: skip);
  }

  String readAll([int? maxLength]) => utf8.decode(_utf8Chars.sublist(
      _offset, maxLength != null ? _offset + maxLength : null));

  int get remaining => _utf8Chars.length - _offset;

  PhpSerializationObjectInformation getObjectInformation(String identifier) {
    return _knownClasses.firstWhere(
        (element) => element.serializedClassName == identifier,
        orElse: () =>
            fallbackObjectDeserialization.handleDeserialization(identifier));
  }
}
