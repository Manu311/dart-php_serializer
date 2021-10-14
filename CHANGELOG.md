## 0.3.2

* Fixed length-calculations for unicode-strings

## 0.3.1

* Removed UsePropertiesOnMissingSerializationInformation from basic-library-code which allows inclusion into flutter-projects once again.

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