class DummyClass {
  DummyClass();

  @override
  bool operator ==(Object other) => other is DummyClass;
}

class ClassWithParameters {
  final int Parameter1;
  final String otherParameter;
  final DummyClass innerClass;
  // ignore: unused_field
  final String _hiddenDuplicate;

  static final int thisShouldNotBeSerialized = 55;
  static const int neitherShouldThisBeSerialized = 50;

  int get parameterViaGetter => Parameter1;
  set parameterViaSetter(int newValue) {}

  ClassWithParameters(
      {required this.Parameter1,
      required this.otherParameter,
      required this.innerClass})
      : _hiddenDuplicate = otherParameter;

  @override
  bool operator ==(Object other) =>
      (other is ClassWithParameters) &&
      (other.Parameter1 == Parameter1) &&
      (other.otherParameter == otherParameter) &&
      (other.innerClass == innerClass);
}
