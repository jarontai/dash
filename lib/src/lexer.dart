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

/// A object represents the basic unit of lexical analysis.
class Token {
  final TokenType tokenType;
  final String literal;

  const Token(this.tokenType, this.literal);

  const Token.identifier(this.literal) : tokenType = TokenType.IDENTIFIER;

  const Token.number(this.literal) : tokenType = TokenType.NUMBER;

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

/// The pre-defined [Token] constants.
abstract class Tokens {
  static const Token illegal = const Token(TokenType.ILLEGAL, 'ILLEGAL');
  static const Token eof = const Token(TokenType.EOF, '');

  static const Token assign = const Token(TokenType.ASSIGN, '=');
  static const Token plus = const Token(TokenType.PLUS, '+');
  static const Token minus = const Token(TokenType.MINUS, '-');
  static const Token mul = const Token(TokenType.MUL, '*');
  static const Token div = const Token(TokenType.DIV, '/');
  static const Token bang = const Token(TokenType.BANG, '!');
  static const Token gt = const Token(TokenType.GT, '>');
  static const Token gte = const Token(TokenType.GTE, '>=');
  static const Token lt = const Token(TokenType.LT, '<');
  static const Token lte = const Token(TokenType.LTE, '<=');
  static const Token eq = const Token(TokenType.EQ, '==');
  static const Token neq = const Token(TokenType.NEQ, '!=');

  static const Token comma = const Token(TokenType.COMMA, ',');
  static const Token semi = const Token(TokenType.SEMI, ';');
  static const Token lparen = const Token(TokenType.LPAREN, '(');
  static const Token rparen = const Token(TokenType.RPAREN, ')');
  static const Token lbrace = const Token(TokenType.LBRACE, '{');
  static const Token rbrace = const Token(TokenType.RBRACE, '}');

  static const Token kVar = const Token(TokenType.VAR, 'var');
  static const Token kReturn = const Token(TokenType.RETURN, 'return');
  static const Token kIf = const Token(TokenType.IF, 'if');
  static const Token kElse = const Token(TokenType.ELSE, 'else');
  static const Token kTrue = const Token(TokenType.TRUE, 'true');
  static const Token kFalse = const Token(TokenType.FALSE, 'false');
}
