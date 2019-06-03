mixin CharHelper {
  static const _laCode = 97;
  static const _lzCode = 122;
  static const _uaCode = 65;
  static const _uzCode = 90;
  static const _0Code = 48;
  static const _9Code = 57;

  bool isLetter(String ch) {
    int code = ch.runes.isEmpty ? 0 : ch.runes.first;
    return (code >= _laCode && code <= _lzCode) ||
        (code >= _uaCode && code <= _uzCode) ||
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
