extension Utf8EncodedStringLength on String {
  ///Equivalent to utf8.encode(this).length, but faster
  int get utf8EncodedLength {
    var returnValue = 0;

    for (var codeUnit in codeUnits) {
      if (codeUnit < 0x80) {
        ++returnValue;
      } else if ((codeUnit & 0xFC00 == 0xD800) ||
          (codeUnit & 0xFC00 == 0xDC00)) {
        returnValue += 2;
      } else {
        if (codeUnit < 0x800) {
          returnValue += 2;
        } else {
          returnValue += 3;
        }
      }
    }

    return returnValue;
  }
}
