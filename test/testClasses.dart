class DummyClass {
  DummyClass();

  @override
  bool operator ==(Object other) => other is DummyClass;
}

class ClassWithParameters {
  final int Parameter1;
  final String otherParameter;
  final DummyClass innerClass;

  ClassWithParameters(
      {required this.Parameter1,
      required this.otherParameter,
      required this.innerClass});

  @override
  bool operator ==(Object other) =>
      (other is ClassWithParameters) &&
      (other.Parameter1 == Parameter1) &&
      (other.otherParameter == otherParameter) &&
      (other.innerClass == innerClass);
}
