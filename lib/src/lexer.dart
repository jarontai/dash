import 'util.dart';

/// The lexer, which response for producing [Token]s from souce code [input].
class Lexer with CharHelper {
  final String input;
  int _position = 0;
  int _readPosition = 0;
  String _ch;
  int _length;
  static final Map<String, Token> _keywordsTokenMap = {
    'var': Tokens.kVar,
    'return': Tokens.kReturn,
    'if': Tokens.kIf,
    'else': Tokens.kElse,
    'true': Tokens.kTrue,
    'false': Tokens.kFalse
  };

  Lexer(this.input) {
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
    while (isLetter(_ch) || isNum(_ch)) {
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

/// A object represents the basic unit of lexical analysis.
class Token {
  final TokenType tokenType;
  final String literal;

  const Token(this.tokenType, this.literal);

  const Token.identifier(this.literal) : tokenType = TokenType.identifier;

  const Token.number(this.literal) : tokenType = TokenType.number;

  String toString() {
    return 'Token(type: $tokenType, literal: $literal)';
  }
}

enum TokenType {
  illegal,
  eof,

  identifier,

  number,
  boolean,

  assign,
  plus,
  minus,
  mul,
  div,
  bang,
  gt,
  gte,
  lt,
  lte,
  eq,
  neq,

  comma,
  semi,
  lparen,
  rparen,
  lbrace,
  rbrace,

  kvar,
  kreturn,
  kif,
  kelse,
  ktrue,
  kfalse,
}

/// The pre-defined [Token] constants.
abstract class Tokens {
  static const Token illegal = const Token(TokenType.illegal, 'ILLEGAL');
  static const Token eof = const Token(TokenType.eof, '');

  static const Token assign = const Token(TokenType.assign, '=');
  static const Token plus = const Token(TokenType.plus, '+');
  static const Token minus = const Token(TokenType.minus, '-');
  static const Token mul = const Token(TokenType.mul, '*');
  static const Token div = const Token(TokenType.div, '/');
  static const Token bang = const Token(TokenType.bang, '!');
  static const Token gt = const Token(TokenType.gt, '>');
  static const Token gte = const Token(TokenType.gte, '>=');
  static const Token lt = const Token(TokenType.lt, '<');
  static const Token lte = const Token(TokenType.lte, '<=');
  static const Token eq = const Token(TokenType.eq, '==');
  static const Token neq = const Token(TokenType.neq, '!=');

  static const Token comma = const Token(TokenType.comma, ',');
  static const Token semi = const Token(TokenType.semi, ';');
  static const Token lparen = const Token(TokenType.lparen, '(');
  static const Token rparen = const Token(TokenType.rparen, ')');
  static const Token lbrace = const Token(TokenType.lbrace, '{');
  static const Token rbrace = const Token(TokenType.rbrace, '}');

  static const Token kVar = const Token(TokenType.kvar, 'var');
  static const Token kReturn = const Token(TokenType.kreturn, 'return');
  static const Token kIf = const Token(TokenType.kif, 'if');
  static const Token kElse = const Token(TokenType.kelse, 'else');
  static const Token kTrue = const Token(TokenType.ktrue, 'true');
  static const Token kFalse = const Token(TokenType.kfalse, 'false');
}
