import 'util.dart';

/// The lexer, which response for producing [Token]s from souce code [input].
class Lexer with CharHelper {
  String input;
  int _position = 0;
  int _readPosition = 0;
  String _ch;
  static final Map<String, Token> _keywordsTokenMap = {
    'var': Tokens.kVar,
    'return': Tokens.kReturn,
    'if': Tokens.kIf,
    'else': Tokens.kElse,
    'true': Tokens.kTrue,
    'false': Tokens.kFalse
  };
  int _length;
  // TODO: use runes for utf8 encoding?
  // List<int> _runes;

  Lexer(this.input) {
    // _runes = input.runes.toList();
    _length = input.length;
    _readChar();
  }

  Token nextToken() {
    // skip whitespaces
    while (isWhitespace(_ch)) {
      _readChar();
    }

    Token token;
    switch (_ch) {
      case '=':
        if (_peekChar() == '=') {
          _readChar();
          token = Tokens.eq;
        } else {
          token = Tokens.assign;
        }
        break;
      case '+':
        token = Tokens.plus;
        break;
      case '-':
        token = Tokens.minus;
        break;
      case '*':
        token = Tokens.mul;
        break;
      case '/':
        token = Tokens.div;
        break;
      case '!':
        if (_peekChar() == '=') {
          _readChar();
          token = Tokens.neq;
        } else {
          token = Tokens.bang;
        }
        break;
      case '>':
        if (_peekChar() == '=') {
          _readChar();
          token = Tokens.gte;
        } else {
          token = Tokens.gt;
        }
        break;
      case '<':
        if (_peekChar() == '=') {
          _readChar();
          token = Tokens.lte;
        } else {
          token = Tokens.lt;
        }
        break;
      case ',':
        token = Tokens.comma;
        break;
      case ';':
        token = Tokens.semi;
        break;
      case '(':
        token = Tokens.lparen;
        break;
      case ')':
        token = Tokens.rparen;
        break;
      case '{':
        token = Tokens.lbrace;
        break;
      case '}':
        token = Tokens.rbrace;
        break;
      case '':
        token = Tokens.eof;
        break;
      default:
        if (isLetter(_ch)) {
          String ident = _readIdentifier();
          return _keywordsTokenMap.containsKey(ident)
              ? _keywordsTokenMap[ident]
              : Token.identifier(ident);
        } else if (isNum(_ch)) {
          return Token.number(_readNumber());
        } else {
          token = Tokens.illegal;
        }
        break;
    }
    _readChar();
    return token;
  }

  _readChar() {
    if (_readPosition >= _length) {
      _ch = '';
    } else {
      _ch = input[_readPosition];
    }
    _position = _readPosition;
    _readPosition += 1;
  }

  String _peekChar() {
    if (_readPosition >= _length) {
      return '';
    } else {
      return input[_readPosition];
    }
  }

  String _readIdentifier() {
    var startPosition = _position;
    _readChar();
    while (isLetter(_ch)) {
      _readChar();
    }
    return input.substring(startPosition, _position);
  }

  String _readNumber() {
    var startPosition = _position;
    _readChar();
    while (isNum(_ch) || _ch == '.') {
      _readChar();
    }
    return input.substring(startPosition, _position);
  }
}

class Token {
  TokenType tokenType;
  String literal;

  Token(this.tokenType, this.literal);

  Token.identifier(this.literal) {
    tokenType = TokenType.IDENTIFIER;
  }

  Token.number(this.literal) {
    tokenType = TokenType.NUMBER;
  }

  String toString() {
    return 'Token(type: $tokenType, literal: $literal)';
  }
}

enum TokenType {
  ILLEGAL,
  EOF,

  IDENTIFIER,

  NUMBER,
  BOOLEAN,

  ASSIGN,
  PLUS,
  MINUS,
  MUL,
  DIV,
  BANG,
  GT,
  GTE,
  LT,
  LTE,
  EQ,
  NEQ,

  COMMA,
  SEMI,
  LPAREN,
  RPAREN,
  LBRACE,
  RBRACE,

  VAR,
  RETURN,
  IF,
  ELSE,
  TRUE,
  FALSE,
}

abstract class Tokens {
  static final Token illegal = Token(TokenType.ILLEGAL, 'ILLEGAL');
  static final Token eof = Token(TokenType.EOF, '');

  static final Token assign = Token(TokenType.ASSIGN, '=');
  static final Token plus = Token(TokenType.PLUS, '+');
  static final Token minus = Token(TokenType.MINUS, '-');
  static final Token mul = Token(TokenType.MUL, '*');
  static final Token div = Token(TokenType.DIV, '/');
  static final Token bang = Token(TokenType.BANG, '!');
  static final Token gt = Token(TokenType.GT, '>');
  static final Token gte = Token(TokenType.GTE, '>=');
  static final Token lt = Token(TokenType.LT, '<');
  static final Token lte = Token(TokenType.LTE, '<=');
  static final Token eq = Token(TokenType.EQ, '==');
  static final Token neq = Token(TokenType.NEQ, '!=');

  static final Token comma = Token(TokenType.COMMA, ',');
  static final Token semi = Token(TokenType.SEMI, ';');
  static final Token lparen = Token(TokenType.LPAREN, '(');
  static final Token rparen = Token(TokenType.RPAREN, ')');
  static final Token lbrace = Token(TokenType.LBRACE, '{');
  static final Token rbrace = Token(TokenType.RBRACE, '}');

  static final Token kVar = Token(TokenType.VAR, 'var');
  static final Token kReturn = Token(TokenType.RETURN, 'return');
  static final Token kIf = Token(TokenType.IF, 'if');
  static final Token kElse = Token(TokenType.ELSE, 'else');
  static final Token kTrue = Token(TokenType.TRUE, 'true');
  static final Token kFalse = Token(TokenType.FALSE, 'false');
}
