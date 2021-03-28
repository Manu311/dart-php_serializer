# php_serializer

Serialize and deserialize Php-Serialized strings

Basically the equivalent to the php-functions
[serialize]{https://www.php.net/manual/de/function.serialize.php} and
[unserialize]{https://www.php.net/manual/de/function.unserialize.php}.
 
## Usage:

If you only need basic objects, simply run [phpSerialize] on any List, Map, String, int or double
and send the resulting String to Php where it can be deserialized with `unserialize()`.

The opposite direction is very similar. Just pass a String generated by Phps `serialize()`-function
to [phpDeserialize] and get the resulting objects.

## Advanced Usage: Objects

If you need additional Objects, which would be encoded with a leading `O:`, these functions require
additional information which have to be provided to enable this functionality.

For every class that should be (de-)serializable there has to be an instance of
[PhpSerializationObjectInformation] which contains the Fully Qualified Class Name from Php
(the classname including the namespace), a method to convert a Dart-object to a list of properties
and another method which does the opposite.

