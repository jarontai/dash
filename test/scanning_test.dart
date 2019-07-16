import 'package:dash/src/scanning/scanner.dart';
import 'package:test/test.dart';

void main() {
  test('basics', () {
    var source = '=+-*/!><,;(){} == != >= <= && ||';

    var expects = [
      TokenType.EQUAL,
      TokenType.PLUS,
      TokenType.MINUS,
      TokenType.STAR,
      TokenType.SLASH,
      TokenType.BANG,
      TokenType.GREATER,
      TokenType.LESS,
      TokenType.COMMA,
      TokenType.SEMICOLON,
      TokenType.LEFT_PAREN,
      TokenType.RIGHT_PAREN,
      TokenType.LEFT_BRACE,
      TokenType.RIGHT_BRACE,
      TokenType.EQUAL_EQUAL,
      TokenType.BANG_EQUAL,
      TokenType.GREATER_EQUAL,
      TokenType.LESS_EQUAL,
      TokenType.AND,
      TokenType.OR,
      TokenType.EOF,
    ];

    var tokens = Scanner(source).scanTokens();

    for (var index = 0; index < tokens.length; index++) {
      expect(tokens[index].type, expects[index]);
    }
  });

  test('literal', () {
    var source = '"test string 1" \'test string 2\' 1 2 3.5';

    var expectTypes = [
      TokenType.STRING,
      TokenType.STRING,
      TokenType.NUMBER,
      TokenType.NUMBER,
      TokenType.NUMBER,
      TokenType.EOF,
    ];
    var expects = [
      'test string 1',
      'test string 2',
      1,
      2,
      3.5,
      null
    ];

    var tokens = Scanner(source).scanTokens();

    for (var index = 0; index < tokens.length; index++) {
      expect(tokens[index].type, expectTypes[index]);
      expect(tokens[index].literal, expects[index]);
    }
  });

  test('keywords', () {
    var source = 'class else false for if null return super this true var while';

    var expects = [
      TokenType.CLASS,
      TokenType.ELSE,
      TokenType.FALSE,
      TokenType.FOR,
      TokenType.IF,
      TokenType.NULL,
      TokenType.RETURN,
      TokenType.SUPER,
      TokenType.THIS,
      TokenType.TRUE,
      TokenType.VAR,
      TokenType.WHILE,
      TokenType.EOF,
    ];

    var tokens = Scanner(source).scanTokens();

    for (var index = 0; index < tokens.length; index++) {
      expect(tokens[index].type, expects[index]);
    }
  });  
}
