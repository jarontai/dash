import 'util.dart';

/// The lexer, which response for producing [Token]s from souce code [input].
class Lexer with CharHelper {
  String input;
  int _position = 0;
  int _readPosition = 0;
  String _ch;
  static final Set<String> _keywordsSet = {
    'var',
    'return',
    'if',
    'else',
    'true',
    'false'
  };
  int _length;
  // TODO: use runes for utf8 encoding?
  // List<int> _runes;

  Lexer(this.input) {
    // _runes = input.runes.toList();
    _length = input.length;
    readChar();
  }

  Token nextToken() {
    // skip whitespaces
    while (isWhitespace(_ch)) {
      readChar();
    }

    Token token;
    switch (_ch) {
      case '=':
        if (peekChar() == '=') {
          readChar();
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
        if (peekChar() == '=') {
          readChar();
          token = Tokens.neq;
        } else {
          token = Tokens.bang;
        }
        break;
      case '>':
        if (peekChar() == '=') {
          readChar();
          token = Tokens.gte;
        } else {
          token = Tokens.gt;
        }
        break;
      case '<':
        if (peekChar() == '=') {
          readChar();
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
          String ident = readIdentifier();
          return _keywordsSet.contains(ident)
              ? Token.keyword(ident)
              : Token.identifier(ident);
        } else if (isNum(_ch)) {
          return Token.number(readNumber());
        } else {
          token = Tokens.illegal;
        }
        break;
    }
    readChar();
    return token;
  }

  readChar() {
    if (_readPosition >= _length) {
      _ch = '';
    } else {
      _ch = input[_readPosition];
    }
    _position = _readPosition;
    _readPosition += 1;
  }

  String peekChar() {
    if (_readPosition >= _length) {
      return '';
    } else {
      return input[_readPosition];
    }
  }

  String readIdentifier() {
    var startPosition = _position;
    readChar();
    while (isLetter(_ch)) {
      readChar();
    }
    return input.substring(startPosition, _position);
  }

  String readNumber() {
    var startPosition = _position;
    readChar();
    while (isNum(_ch) || _ch == '.') {
      readChar();
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

  Token.keyword(this.literal) {
    tokenType = TokenType.KEYWORD;
  }

  Token.number(this.literal) {
    tokenType = TokenType.NUMBER;
  }

  String toString() {
    return '{ Type: $tokenType, Literal: $literal }';
  }
}

enum TokenType {
  ILLEGAL,
  EOF,

  IDENTIFIER,
  KEYWORD,

  NUMBER,
  BOOLEAN,

  OPERATOR,

  COMMA,
  SEMI,
  LPAREN,
  RPAREN,
  LBRACE,
  RBRACE,
}

abstract class Tokens {
  static final Token illegal = Token(TokenType.ILLEGAL, 'ILLEGAL');
  static final Token eof = Token(TokenType.EOF, '');

  static final Token assign = Token(TokenType.OPERATOR, '=');
  static final Token plus = Token(TokenType.OPERATOR, '+');
  static final Token minus = Token(TokenType.OPERATOR, '-');
  static final Token mul = Token(TokenType.OPERATOR, '*');
  static final Token div = Token(TokenType.OPERATOR, '/');
  static final Token bang = Token(TokenType.OPERATOR, '!');
  static final Token gt = Token(TokenType.OPERATOR, '>');
  static final Token gte = Token(TokenType.OPERATOR, '>=');
  static final Token lt = Token(TokenType.OPERATOR, '<');
  static final Token lte = Token(TokenType.OPERATOR, '<=');
  static final Token eq = Token(TokenType.OPERATOR, '==');
  static final Token neq = Token(TokenType.OPERATOR, '!=');

  static final Token comma = Token(TokenType.COMMA, ',');
  static final Token semi = Token(TokenType.SEMI, ';');
  static final Token lparen = Token(TokenType.LPAREN, '(');
  static final Token rparen = Token(TokenType.RPAREN, ')');
  static final Token lbrace = Token(TokenType.LBRACE, '{');
  static final Token rbrace = Token(TokenType.RBRACE, '}');

  static final Token kVar = Token(TokenType.KEYWORD, 'var');
  static final Token kReturn = Token(TokenType.KEYWORD, 'return');
  static final Token kIf = Token(TokenType.KEYWORD, 'if');
  static final Token kElse = Token(TokenType.KEYWORD, 'else');
  static final Token kTrue = Token(TokenType.KEYWORD, 'true');
  static final Token kFalse = Token(TokenType.KEYWORD, 'false');
}
