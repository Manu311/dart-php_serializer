class DummyClass {
  const DummyClass();

  @override
  bool operator ==(Object other) => other is DummyClass;

  @override
  int get hashCode => 1;
}

class ClassWithParameters {
  final int parameter1;
  final String otherParameter;
  final DummyClass innerClass;
  // ignore: unused_field
  final String _hiddenDuplicate;

  static final int thisShouldNotBeSerialized = 55;
  static const int neitherShouldThisBeSerialized = 50;

  int get parameterViaGetter => parameter1;
  set parameterViaSetter(int newValue) {}

  const ClassWithParameters(
      {required this.parameter1,
      required this.otherParameter,
      required this.innerClass})
      : _hiddenDuplicate = otherParameter;

  @override
  bool operator ==(Object other) =>
      (other is ClassWithParameters) &&
      (other.parameter1 == parameter1) &&
      (other.otherParameter == otherParameter) &&
      (other.innerClass == innerClass);

  @override
  int get hashCode => parameter1 ^ otherParameter.length ^ innerClass.hashCode;
}
