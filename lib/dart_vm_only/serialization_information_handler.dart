import 'package:php_serializer/php_serializer.dart';

import './dummy_mirrors.dart' if (dart.library.mirrors) 'dart:mirrors';

/// Serializes classes by inspecting their properties and automatically
/// converting them into php-properties.
/// Optionally, if [inspectPrivate] is set to true, it will also inspect
/// private properties. If [inspectGetters] is set to true, it will
/// additionally inspect getters.
/// Both options can be combined to also inspect private getters.
///
/// This Handler is only usable on the dart-vm. Neither on the web nor
/// when using Flutter. Do not import this file if running on Flutter!
/// {@category Fallback Behavior}
class UsePropertiesOnMissingSerializationInformation
    implements NoMatchingObjectSerializationInformation {
  final bool inspectPrivate;
  final bool inspectGetters;

  UsePropertiesOnMissingSerializationInformation({
    this.inspectPrivate = false,
    this.inspectGetters = false,
  });

  @override
  PhpSerializationObjectInformation<Object> handleSerialization(
      Type objectType) {
    if (!bool.fromEnvironment('dart.library.mirrors')) {
      throw UnsupportedError('Platform not supported');
    }
    return _UsePropertiesOfClass(
      objectType,
      inspectPrivate: inspectPrivate,
      inspectGetters: inspectGetters,
    );
  }
}

class _UsePropertiesOfClass implements PhpSerializationObjectInformation {
  final Type _type;
  final bool inspectPrivate;
  final bool inspectGetters;

  _UsePropertiesOfClass(this._type,
      {this.inspectPrivate = false, this.inspectGetters = false});

  @override
  Object Function(Map<String, dynamic> map) get objectGenerator =>
      throw UnimplementedError();

  @override
  Map<String, dynamic> Function(Object instance) get dataExtractor {
    return (Object instance) {
      final mirror = reflect(instance);
      final declarationMirrors = mirror.type.declarations.values;

      final returnValue = <String, dynamic>{};

      for (final declaration in declarationMirrors) {
        if (declaration is VariableMirror) {
          if (declaration.isStatic ||
              (declaration.isPrivate && !inspectPrivate) ||
              declaration.isConst) {
            continue;
          }
          returnValue[MirrorSystem.getName(declaration.simpleName)] =
              mirror.getField(declaration.simpleName).reflectee;
        } else if (declaration is MethodMirror) {
          if (!inspectGetters ||
              !declaration.isGetter ||
              (declaration.isPrivate && !inspectPrivate)) {
            continue;
          }
          returnValue[MirrorSystem.getName(declaration.simpleName)] =
              mirror.getField(declaration.simpleName).reflectee;
        }
      }
      return returnValue;
    };
  }

  @override
  String get serializedClassName {
    return _type.toString();
  }

  @override
  Type get typeOf => _type;
}
