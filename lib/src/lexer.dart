import 'util.dart';

/// The lexer, which response for producing [Token]s from souce code [input].
class Lexer with CharHelper {
  String input;
  int position = 0;
  int readPosition = 0;
  String ch;
  static final Set<String> _keywordsSet = {'var', 'return'};

  // TODO: use runes for utf8 encoding?
  // List<int> _runes;

  Lexer(this.input) {
    // _runes = input.runes.toList();
    readChar();
  }

  Token nextToken() {
    // skip whitespaces
    while (isWhitespace(ch)) {
      readChar();
    }

    Token token;
    switch (ch) {
      case '=':
        token = Tokens.assign;
        break;
      case ',':
        token = Tokens.comma;
        break;
      case ';':
        token = Tokens.semi;
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
        if (isLetter(ch)) {
          String ident = readIdentifier();
          token = _keywordsSet.contains(ident)
              ? Token.keyword(ident)
              : Token.identifier(ident);
          return token;
        } else if (isNum(ch)) {
          token = Token.number(readNumber());
          return token;
        } else {
          token = Tokens.illegal;
        }
        break;
    }
    readChar();
    return token;
  }

  readChar() {
    if (readPosition >= input.length) {
      ch = '';
    } else {
      ch = input[readPosition];
    }
    position = readPosition;
    readPosition += 1;
  }

  String readIdentifier() {
    var startPosition = position;
    readChar();
    while (isLetter(ch)) {
      readChar();
    }
    return input.substring(startPosition, position);
  }

  String readNumber() {
    var startPosition = position;
    readChar();
    while (isNum(ch) || ch == '.') {
      readChar();
    }
    return input.substring(startPosition, position);    
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

  // Token.db(this.literal) {
  //   tokenType = TokenType.DOUBLE;
  // }
}

enum TokenType {
  ILLEGAL,
  EOF,

  IDENTIFIER,
  NUMBER,
  DOUBLE,
  BOOLEAN,

  ASSIGN,
  PLUS,
  MINUS,

  COMMA,
  SEMI,
  LPAREN,
  RPAREN,
  LBRACE,
  RBRACE,

  KEYWORD,
}

abstract class Tokens {
  static final Token illegal = Token(TokenType.ILLEGAL, 'ILLEGAL');
  static final Token eof = Token(TokenType.ILLEGAL, '');

  // static final Token IDENTIFIER = "IDENTIFIER";
  // static final Token INT = "INT";
  // static final Token DOUBLE = "DOUBLE";
  // static final Token BOOLEAN = "BOOLEAN";

  static final Token assign = Token(TokenType.ASSIGN, '=');
  static final Token plus = Token(TokenType.PLUS, '+');
  static final Token minus = Token(TokenType.PLUS, '-');
  static final Token mul = Token(TokenType.PLUS, '*');
  static final Token div = Token(TokenType.PLUS, '/');

  static final Token comma = Token(TokenType.COMMA, ',');
  static final Token semi = Token(TokenType.SEMI, ';');
  static final Token lparen = Token(TokenType.LPAREN, '(');
  static final Token rparen = Token(TokenType.RPAREN, ')');
  static final Token lbrace = Token(TokenType.LBRACE, '{');
  static final Token rbrace = Token(TokenType.RBRACE, '}');

  static final Token kVar = Token(TokenType.KEYWORD, 'var');
  static final Token kReturn = Token(TokenType.KEYWORD, 'return');
}
