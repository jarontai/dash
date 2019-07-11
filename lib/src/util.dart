const _lowerA = 97;
const _lowerZ = 122;
const _upperA = 65;
const _upperZ = 90;
const _0Code = 48;
const _9Code = 57;

bool isAlpha(String ch) {
  int code = ch.runes.isEmpty ? 0 : ch.runes.first;
  return (code >= _lowerA && code <= _lowerZ) ||
      (code >= _upperA && code <= _upperZ) ||
      (ch == '_');
}

bool isAlphaNumeric(String ch) {
  return isAlpha(ch) || isDigit(ch);
}

bool isDigit(String ch) {
  int code = ch.runes.isEmpty ? 0 : ch.runes.first;
  return code >= _0Code && code <= _9Code;
}

bool isWhitespace(String ch) {
  return (ch == ' ') || (ch == '\t') || (ch == '\r') || (ch == '\n');
}
