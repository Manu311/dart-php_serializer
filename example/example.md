# Transfer data from Php to Dart

```php
<?php
$trivialArray = [
    1, 1, 2, 3, 5, 8
];
echo serialize($trivialArray);
//Output: a:6:{i:0;i:1;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:5;i:5;i:8;}
```

```dart
void main() {
  String inputFromPhp = 'a:6:{i:0;i:1;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:5;i:5;i:8;}';
  assert([1, 1, 2, 3, 5, 8] == phpDeserialize(inputFromPhp));
}
```

# Transfer data from Dart to Php

```dart
void main() {
  List<int> trivialList = [1, 1, 2, 3, 5, 8];
  print(phpSerialize(trivialList));
  //Output: a:6:{i:0;i:1;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:5;i:5;i:8;}
}
```

```php
<?php
$inputFromDart = 'a:6:{i:0;i:1;i:1;i:1;i:2;i:2;i:3;i:3;i:4;i:5;i:5;i:8;}';
\assert([1, 1, 2, 3, 5, 8] === unserialize($inputFromDart));
```
