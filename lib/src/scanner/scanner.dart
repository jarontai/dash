import '../runner.dart';
import '../util.dart' as util;
import 'token.dart';

export 'token.dart';

/// The scanner or lexer, which response for producing [Token]s from souce code.
class Scanner {
  final String _source;
  final List<Token> _tokens = [];
  int _start = 0;
  int _current = 0;
  int _line = 1;
  final Map<String, TokenType> _keywords = {
    'class': TokenType.CLASS,
    'else': TokenType.ELSE,
    'false': TokenType.FALSE,
    'for': TokenType.FOR,
    'if': TokenType.IF,
    'null': TokenType.NULL,
    'return': TokenType.RETURN,
    'super': TokenType.SUPER,
    'this': TokenType.THIS,
    'true': TokenType.TRUE,
    'var': TokenType.VAR,
    'while': TokenType.WHILE,
  };

  Scanner(this._source);

  void identifier() {
    while (util.isAlphaNumeric(_peek())) {
      _advance();
    }

    var text = _source.substring(_start, _current);
    var type = _keywords[text] ?? TokenType.IDENTIFIER;

    _addToken(type);
  }

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }

    _tokens.add(Token(TokenType.EOF, '', null, _line));
    return _tokens;
  }

  void _addToken(TokenType type, {Object literal}) {
    var text = _source.substring(_start, _current);
    _tokens.add(Token(type, text, literal, _line));
  }

  String _advance() {
    _current++;
    return _source[_current - 1];
  }

  bool _isAtEnd() => _current >= _source.length;

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (_source[_current] != expected) return false;
    _current++;
    return true;
  }

  void _number() {
    while (util.isDigit(_peek())) {
      _advance();
    }

    if (_peek() == '.' && util.isDigit(_peekNext())) {
      _advance();

      while (util.isDigit(_peek())) {
        _advance();
      }
    }

    _addToken(TokenType.NUMBER,
        literal: num.tryParse(_source.substring(_start, _current)));
  }

  String _peek() => _isAtEnd() ? '' : _source[_current];

  String _peekNext() {
    if ((_current + 1) >= _source.length) return '';
    return _source[_current + 1];
  }

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
      case '&':
        if (_match('&')) {
          _addToken(TokenType.AND);
        } else {
          Runner.error(_line, 'Unexpected character.');
        }
        break;
      case '|':
        if (_match('|')) {
          _addToken(TokenType.OR);
        } else {
          Runner.error(_line, 'Unexpected character.');
        }
        break;

      case ' ':
      case '\r':
      case '\t':
        break;

      case '\n':
        _line++;
        break;

      case '\'':
        _string('\'');
        break;
      case '"':
        _string('"');
        break;

      default:
        if (util.isDigit(char)) {
          _number();
        } else if (util.isAlpha(char)) {
          identifier();
        } else {
          Runner.error(_line, 'Unexpected character.');
        }
        break;
    }
  }

  void _string(String quote) {
    while (_peek() != quote && !_isAtEnd()) {
      if (_peek() == '\n') _line++;
      _advance();
    }

    if (_isAtEnd()) {
      Runner.error(_line, 'Unterminated string.');
      return;
    }

    _advance();

    var value = _source.substring(_start + 1, _current - 1);
    _addToken(TokenType.STRING, literal: value);
  }
}
