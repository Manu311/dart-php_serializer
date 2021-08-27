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

  dynamic _parse(_StringRepresentation repr) {
    final identifier = repr.read(1, skip: 1);

    switch (identifier) {
      case 's':
        return _parseString(repr);
      case 'i':
        return _parseInt(repr);
      case 'd':
        return _parseDouble(repr);
      case 'a':
        return _parseArray(repr);
      case 'O':
        return _parseObject(repr);
      case 'N':
        return null;
      case 'b':
        return (repr.read(2) == '1;');
      default:
        throw InvalidSerializedString(repr.readAll());
    }
  }

  String _parseString(_StringRepresentation repr) {
    final lengthOfString = int.parse(repr.readUntil(skip: 2));
    final returnValue = repr.read(lengthOfString, skip: 2);
    return returnValue;
  }

  int _parseInt(_StringRepresentation repr) {
    final returnValue = repr.readUntil(pattern: r';', skip: 1);
    return int.parse(returnValue);
  }

  double _parseDouble(_StringRepresentation repr) {
    final returnValue = repr.readUntil(pattern: r';', skip: 1);
    return double.parse(returnValue);
  }

  dynamic _parseArray(_StringRepresentation repr,
      {bool allowSimplifiacation = true}) {
    final arrayLength = int.parse(repr.readUntil(pattern: r':', skip: 2));
    final possibleReturnValue = <dynamic, dynamic>{};
    var canBeSimplified = allowSimplifiacation;

    for (var i = 0; i != arrayLength; ++i) {
      final key = _parse(repr);
      if (canBeSimplified && (!(key is int) || key != i)) {
        canBeSimplified = false;
      }
      final value = _parse(repr);
      possibleReturnValue[key] = value;
    }
    repr.skip(); //}

    if (canBeSimplified) {
      return List<dynamic>.generate(
          possibleReturnValue.length, (index) => possibleReturnValue[index]);
    }

    return possibleReturnValue;
  }

  dynamic _parseObject(_StringRepresentation repr) {
    final lengthOfName = int.parse(repr.readUntil(pattern: r':', skip: 2));
    final classIdentifier = repr.read(lengthOfName, skip: 2);
    final parameterArray = Map<String, dynamic>.from(
        _parseArray(repr, allowSimplifiacation: false));
    final objectInfo = repr.getObjectInformation(classIdentifier);
    try {
      return objectInfo.objectGenerator(parameterArray);
    } catch (e) {
      throw CustomDeserializationFailed(objectInfo.typeOf, e);
    }
  }
}

class _StringRepresentation {
  final String _rawString;
  int _offset = 0;
  final List<PhpSerializationObjectInformation> _knownClasses;
  final NoMatchingObjectDeserializationInformation
      fallbackObjectDeserialization;

  _StringRepresentation(
      this._rawString, this._knownClasses, this.fallbackObjectDeserialization);

  void skip([int length = 1]) {
    _offset += length;
  }

  String read(int length, {int skip = 0}) {
    assert(!isDone);
    if (length > remaining) length = remaining;
    _offset += length;
    final returnValue = _rawString.substring(_offset - length, _offset);
    this.skip(skip);
    return returnValue;
  }

  String readUntil({String pattern = ':', int skip = 0}) {
    assert(!isDone);
    final offset = _offset;
    _offset = _rawString.indexOf(pattern, _offset);
    final returnValue = _rawString.substring(offset, _offset);
    this.skip(skip);
    return returnValue;
  }

  String readAll() => _rawString.substring(_offset);

  bool get isDone => _offset == _rawString.length;

  int get remaining => _rawString.length - _offset;

  PhpSerializationObjectInformation getObjectInformation(String identifier) {
    return _knownClasses.firstWhere(
        (element) => element.serializedClassName == identifier,
        orElse: () =>
            fallbackObjectDeserialization.handleDeserialization(identifier));
  }
}
