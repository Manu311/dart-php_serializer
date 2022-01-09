# Automatically convert objects (with datetime as example):

Generating and serializing objects requires additional work for each class.
Simple functions need to be provided, which will be used to transform Maps to object instances or extract a map from our instance.
For our example of DateTime, these are rather simple:
```dart
final dateTimeConversion = PhpSerializationObjectInformation<DateTime>(
  'DateTime',
  dataExtractor: (dateTime) => {
    'date': (dateTime as DateTime).toString(),
    'timezone_type': 3,
    'timezone': 'UTC',
  },
  objectGenerator: (map) => DateTime.parse(map['date']),
);
```
Coincidentally the format which Dart and Php use for their datetime-objects are identical, but any transformation would be possible in these functions.
Timezone aren't easily extractable/converted, so they are just hard coded for serialization and ignored for deserialization.

With this definition serialization and deserialization are trivial:
```dart
final serializedByPhp =
    'O:8:"DateTime":3:{s:4:"date";s:26:"2022-01-09 15:18:18.015520";s:13:"timezone_type";i:3;s:8:"timezone";s:3:"UTC";}';
final DateTime dateTime = phpDeserialize(inputString, knownClasses: [dateTimeConversion]);
```

```dart
final dateTime = DateTime(2022, 1, 9, 15, 18, 18, 015, 520);
final String serializedForPhp = phpSerialize(dateTime, knownClasses: [dateTimeConversion]);
```