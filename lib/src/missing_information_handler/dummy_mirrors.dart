InstanceMirror reflect(dynamic reflectee) {
  throw UnsupportedError('Platform not supported');
}

abstract class MirrorSystem {
  static String getName(Symbol symbol) => '';
}

abstract class MethodMirror {}

abstract class VariableMirror {
  bool get isStatic;
  bool get isConst;
}

abstract class DeclarationMirror {
  bool get isStatic;
  bool get isConst;
  bool get isPrivate;
  bool get isGetter;
  Symbol get simpleName;
}

abstract class ClassMirror {
  Map<Symbol, DeclarationMirror> get declarations;
}

abstract class ObjectMirror {
  InstanceMirror getField(Symbol fieldName);
}

abstract class InstanceMirror implements ObjectMirror {
  ClassMirror get type;
  dynamic get reflectee;
}
