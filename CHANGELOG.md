## 1.0.0-pre.4

* Improved performance when handling strings

## 1.0.0-pre.3

* Fixed length-calculations for unicode-strings
* Added const constructors to most classes
* Changed interface of PhpSerializationObjectInformation to use optional named properties instead of required position dependant ones

## 1.0.0-pre.2

* Removed UsePropertiesOnMissingSerializationInformation from basic-library-code which allows inclusion into flutter-projects once again.

## 1.0.0-pre.1

* Changed interface of phpSerialize to use named properties instead of position dependant ones
* Changed interface of phpDeserialize to use named properties instead of position dependant ones

## 0.3.0

* Added support to implement custom handlers in case of missing serialization or deserialization information for objects
* Added default handlers which throw identical exceptions than previously
* Added new serialization handler UsePropertiesOnMissingSerializationInformation which uses reflection to identify properties
* Added new deserialization handler GenerateMapOnMissingDeserializationInformation which forwards the internal data-map as the deserialized object
* Added new deserialization handler GenerateDartClassCodeOnMissingDeserializationInformation which generates String-objects holding dart-code for this class
* Fixed floating point number serialization test which allows testing with DartJs
* Restructured files into src directory

## 0.2.0

* Added boolean values
* Added null values
## 0.1.2

* Reformated files according to dart format
## 0.1.1

* Fixed analyser findings
## 0.1.0

* Initial Release
* Features should all be available