class Lexer {
  String input;
  int position = 0;
  int readPosition = 0;
  String ch;
  // List<int> _runes;
  

  Lexer(this.input) {
    // _runes = input.runes.toList();
    readChar();
  }

  Token nextToken() {
    Token token;
    switch (ch) {
      case '=':
        token = Tokens.assign;
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
      case ',':
        token = Tokens.comma;
        break;
      case '+':
        token = Tokens.plus;
        break;
      case '':
        token = Tokens.eof;
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
}

class Token {
  TokenType tokenType;
  String literal;

  Token(this.tokenType, this.literal);

  Token.identifier(this.literal) {
    tokenType = TokenType.IDENTIFIER;
  }

  Token.integer(this.literal) {
    tokenType = TokenType.INTEGER;
  }

  Token.db(this.literal) {
    tokenType = TokenType.DOUBLE;
  }
}

enum TokenType {
  ILLEGAL,
  EOF,

  IDENTIFIER,
  INTEGER,
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

  VAR,
}

abstract class Tokens {
  static final Token illegal = Token(TokenType.ILLEGAL, 'ILLEGAL');
  static final Token eof = Token(TokenType.ILLEGAL, '');

  // static final Token IDENTIFIER = "IDENTIFIER";
  // static final Token INT = "INT";
  // static final Token DOUBLE = "DOUBLE";
  // static final Token BOOLEAN = "BOOLEAN";

  static final Token assign = Token(TokenType.ASSIGN, '=');
  static final Token plus = Token(TokenType.PLUS, '-');

  static final Token comma = Token(TokenType.COMMA, ',');
  static final Token semi = Token(TokenType.SEMI, ';');
  static final Token lparen = Token(TokenType.LPAREN, '(');
  static final Token rparen = Token(TokenType.RPAREN, ')');
  static final Token lbrace = Token(TokenType.LBRACE, '{');
  static final Token rbrace = Token(TokenType.RBRACE, '}');

  static final Token kVar = Token(TokenType.VAR, 'var');
}