import 'token.dart';
import 'dash.dart';

class Scanner {
  final String _source;
  final List<Token> _tokens = [];
  int _start = 0;
  int _current = 0;
  int _line = 1;

  Scanner(this._source);

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }

    _tokens.add(Token(TokenType.EOF, '', null, _line));
    return _tokens;
  }

  bool _isAtEnd() => _current >= _source.length;

  void _scanToken() {
    var char = _advance();
    switch (char) {
      case '(':
        _addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        _addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        _addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        _addToken(TokenType.RIGHT_BRACE);
        break;
      case ',':
        _addToken(TokenType.COMMA);
        break;
      case '.':
        _addToken(TokenType.DOT);
        break;
      case '-':
        _addToken(TokenType.MINUS);
        break;
      case '+':
        _addToken(TokenType.PLUS);
        break;
      case ';':
        _addToken(TokenType.SEMICOLON);
        break;
      case '*':
        _addToken(TokenType.STAR);
        break;
      case '!':
        _addToken(_match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
        break;
      case '=':
        _addToken(_match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
        break;
      case '<':
        _addToken(_match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
        break;
      case '>':
        _addToken(_match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
        break;
      case '/':
        if (_match('/')) {
          while (_peek() != '\n' && !_isAtEnd()) {
            _advance();
          }
        } else {
          _addToken(TokenType.SLASH);
        }
        break;

      case ' ':
      case '\r':
      case '\t':
        break;
      
      case '\n':
        _line++;
        break;

      default:
        Dash.error(_line, 'Unexpected character.');
        break;
    }
  }

  String _advance() {
    _current++;
    return _source[_current - 1];
  }

  void _addToken(TokenType type, {Object literal}) {
    var text = _source.substring(_start, _current);
    _tokens.add(Token(type, text, literal, _line));
  }

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (_source[_current] != expected) return false;
    _current++;
    return true;
  }

  String _peek() => _isAtEnd() ? '\0' : _source[_current];
}
