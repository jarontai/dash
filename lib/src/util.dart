mixin CharHelper {
  static const _lowerA = 97;
  static const _lowerZ = 122;
  static const _upperA = 65;
  static const _upperZ = 90;
  static const _0Code = 48;
  static const _9Code = 57;

  bool isLetter(String ch) {
    int code = ch.runes.isEmpty ? 0 : ch.runes.first;
    return (code >= _lowerA && code <= _lowerZ) ||
        (code >= _upperA && code <= _upperZ) ||
        (ch == '_');
  }

  bool isWhitespace(String ch) {
    return (ch == ' ') || (ch == '\t') || (ch == '\r') || (ch == '\n');
  }

  bool isNum(String ch) {
    int code = ch.runes.isEmpty ? 0 : ch.runes.first;
    return code >= _0Code && code <= _9Code;
  }
}
