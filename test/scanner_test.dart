import 'package:dash/src/scanner.dart';
import 'package:test/test.dart';

void main() {
  test('basic', () {
    var source = '=+-*/!><,;(){} == != >= <= ';

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
      TokenType.EOF,
    ];

    var tokens = Scanner(source).scanTokens();

    for (var index = 0; index < tokens.length; index++) {
      expect(tokens[index].type, expects[index]);
    }
  });

  test('literal', () {
    var source = '"test string 1" \'test string 2\' 1 2 3.5';

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
      expect(tokens[index].literal, expects[index]);
    }
  });
}
