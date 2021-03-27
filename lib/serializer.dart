import 'package:php_serializer/php_serializer.dart';

class Serializer {
  static String parse(dynamic rawInput) {
    switch (rawInput.runtimeType) {
      case String:
        return _parseString(rawInput);
      case int:
        return _parseInt(rawInput);
      default:
    }

    if (rawInput is List) {
      return _parseList(rawInput);
    }

    if (rawInput is Map) {
      return _parseMap(rawInput);
    }

    if (rawInput is PhpSerializableClass) {
      return _parseSerializableClass(rawInput);
    }

    throw UnimplementedError(
        'Object not supported: ${rawInput.runtimeType.toString()}');
  }

  static String _parseString(String inputString) {
    return 's:${inputString.length}:"${inputString}";';
  }

  static String _parseInt(int inputInt) {
    return 'i:${inputInt};';
  }

  static String _parseList(List<dynamic> inputList) {
    final sb = StringBuffer('a:${inputList.length}:{');
    for (var i = 0; i != inputList.length; ++i) {
      sb.write('i:${i};');
      sb.write(parse(inputList[i]));
    }

    sb.write('}');
    return sb.toString();
  }

  static String _parseMap(Map<dynamic, dynamic> inputMap,
      {bool prependArrayIdentifierAndSize = true}) {
    final sb = StringBuffer();
    if (prependArrayIdentifierAndSize)
      sb.write('a:${inputMap.length}:');
    sb.write('{');

    inputMap.forEach((key, value) {
      sb.write('${parse(key)}${parse(value)}');
    });

    sb.write('}');
    return sb.toString();
  }

  static String _parseSerializableClass(PhpSerializableClass inputClass) {
    final className = inputClass.uniqueNameForPhpSerialization;
    final intermediateMap = inputClass.serializedMapForPhp;
    final serializer = _parseMap(intermediateMap, prependArrayIdentifierAndSize: false);
    return 'O:${className.length}:"${className}":${intermediateMap.length}:${serializer}';
  }
}
