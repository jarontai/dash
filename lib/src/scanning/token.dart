// The minimal unit of lexcial analysis
class Token {
  final TokenType type;
  final String lexeme;
  final Object literal;
  final int line;

  Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString() {
    return '$type ${lexeme ?? ''} ${literal ?? ''}';
  }
}

enum TokenType {
  // Single-character tokens.
  LEFT_PAREN, // (
  RIGHT_PAREN, // )
  LEFT_BRACE, // {
  RIGHT_BRACE, // }
  COMMA, // ,
  DOT, // .
  MINUS, // -
  PLUS, // +
  SEMICOLON, // ;
  SLASH, // /
  STAR,// *

  // One or two character tokens.
  BANG, // !
  BANG_EQUAL, // !=
  EQUAL, // =
  EQUAL_EQUAL, // ==
  GREATER, // >
  GREATER_EQUAL, // >=
  LESS, // <
  LESS_EQUAL, // <=
  BIT_AND, // &
  BIT_OR, // |
  LOGIC_AND, // &&
  LOGIC_OR, // ||

  // Literals.
  IDENTIFIER,
  STRING,
  NUMBER,

  // Keywords.
  
  CLASS,
  ELSE,
  FALSE,
  FOR,
  IF,
  NULL,
  RETURN,
  SUPER,
  THIS,
  TRUE,
  VAR,
  WHILE,

  EOF
}
