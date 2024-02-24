import 'package:php_serializer/php_serializer.dart';

/// Throws an exception of type [DeserializationException] if there is no
/// matching [PhpSerializationObjectInformation] for a class.
/// {@category Fallback Behavior}
class ThrowExceptionOnMissingDeserializationInformation
    implements NoMatchingObjectDeserializationInformation {
  const ThrowExceptionOnMissingDeserializationInformation();

  @override
  PhpSerializationObjectInformation<Object> handleDeserialization(
      String classIdentifier) {
    throw ObjectWithoutDeserializationInformationFound(classIdentifier);
  }
}

/// Generates a [Map]<String, dynamic> for objects that do not have matching
/// [PhpSerializationObjectInformation].
/// {@category Fallback Behavior}
class GenerateMapOnMissingDeserializationInformation
    implements NoMatchingObjectDeserializationInformation {
  const GenerateMapOnMissingDeserializationInformation();

  @override
  PhpSerializationObjectInformation<Object> handleDeserialization(
          String classIdentifier) =>
      const _GenerateMap();
}

class _GenerateMap implements PhpSerializationObjectInformation {
  const _GenerateMap();

  @override
  Map<String, dynamic> Function(Object instance) get dataExtractor =>
      throw UnimplementedError();

  @override
  Object Function(Map<String, dynamic> map) get objectGenerator {
    return (Map<String, dynamic> map) => map;
  }

  @override
  String get serializedClassName => throw UnimplementedError();

  @override
  Type get typeOf => Map;
}

/// Generates dart code representing the passed instance
/// The generated class contains all properties as final properties which
/// allows the class-instances to be const.
/// Additionally a static property phpSerializationObjectInformation is created
/// which can be passed to [phpSerialize] and [phpDeserialize].
/// {@category Fallback Behavior}
class GenerateDartClassCodeOnMissingDeserializationInformation
    implements NoMatchingObjectDeserializationInformation {
  const GenerateDartClassCodeOnMissingDeserializationInformation();

  @override
  PhpSerializationObjectInformation<Object> handleDeserialization(
      String classIdentifier) {
    return _GenerateDartClassCode(classIdentifier);
  }
}

class _GenerateDartClassCode implements PhpSerializationObjectInformation {
  final String _classIdentifier;

  const _GenerateDartClassCode(this._classIdentifier);

  @override
  Map<String, dynamic> Function(Object instance) get dataExtractor =>
      throw UnimplementedError();

  @override
  Object Function(Map<String, dynamic> map) get objectGenerator {
    return (Map<String, dynamic> map) {
      final sb = StringBuffer('class $_classIdentifier {\n');

      sb.writeAll(_getPropertyDeclarations(map));
      _writeConstructorDeclaration(map, sb);
      _writePhpSerializationObjectInformationDeclaration(sb, map);

      sb.write('}\n');

      return sb.toString();
    };
  }

  void _writePhpSerializationObjectInformationDeclaration(
      StringBuffer sb, Map<String, dynamic> map) {
    sb.write('''

  static final phpSerializationObjectInformation =
  PhpSerializationObjectInformation<$_classIdentifier>(
    '$_classIdentifier',
        (Map<String, dynamic> map) =>
        $_classIdentifier(''');
    sb.write(map.entries
        .map((e) => '\n              ${e.key}: map[\'${e.key}\']')
        .join(','));
    sb.write('''),
    (Object instance) =>
    <String, dynamic>{''');
    sb.write(map.entries
        .map((e) => '\n        \'${e.key}\': instance.${e.key}')
        .join(','));
    sb.write('\n    });\n');
  }

  void _writeConstructorDeclaration(Map<String, dynamic> map, StringBuffer sb) {
    if (map.isNotEmpty) {
      sb.write('\n  const $_classIdentifier({');
      sb.write(
          map.entries.map((e) => '\n      required this.${e.key}').join(','));
      sb.write('\n  });\n');
    }
  }

  Iterable<dynamic> _getPropertyDeclarations(Map<String, dynamic> map) {
    return map.entries.map((e) {
      late final String propertyType;

      if (e.value is String && (e.value as String).startsWith('class ')) {
        final endOfClassName = (e.value as String).indexOf(' {\n');
        propertyType = (e.value as String).substring(6, endOfClassName);
      } else {
        propertyType = e.value.runtimeType.toString();
      }

      return '  final $propertyType ${e.key};\n';
    });
  }

  @override
  String get serializedClassName => throw UnimplementedError();

  @override
  Type get typeOf => String;
}
