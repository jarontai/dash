import 'package:dash/dash.dart';
import 'package:test/test.dart';

void main() {
  test('basic', () {
    var input = '=+(){},;';

    var expectTokens = [
      Tokens.assign,
      Tokens.plus,
      Tokens.lparen,
      Tokens.rparen,
      Tokens.lbrace,
      Tokens.rbrace,
      Tokens.comma,
      Tokens.semi,
      Tokens.eof,
    ];

    Lexer lexer = Lexer(input);

    for (var token in expectTokens) {
      var tok = lexer.nextToken();
      expect(tok.tokenType, token.tokenType);
      expect(tok.literal, token.literal);
    }
  });

  test('function', () {
    var input = '''var one = 1;
      var tpf = 2.5;

      var add = (x, y) {
        return x + y;
      };

      var result = add(one, tpf);''';

    var expectTokens = [
      Tokens.kVar,
      Token.identifier('one'),
      Tokens.assign,
      Token.number('1'),
      Tokens.semi,
      Tokens.kVar,
      Token.identifier('tpf'),
      Tokens.assign,
      Token.number('2.5'),
      Tokens.semi,
      Tokens.kVar,
      Token.identifier('add'),
      Tokens.assign,
      Tokens.lparen,
      Token.identifier('x'),
      Tokens.comma,
      Token.identifier('y'),
      Tokens.rparen,
      Tokens.lbrace,
      Tokens.kReturn,
      Token.identifier('x'),
      Tokens.plus,
      Token.identifier('y'),
      Tokens.semi,
      Tokens.rbrace,
      Tokens.semi,
      Tokens.kVar,
      Token.identifier('result'),
      Tokens.assign,
      Token.identifier('add'),
      Tokens.lparen,
      Token.identifier('one'),
      Tokens.comma,
      Token.identifier('tpf'),
      Tokens.rparen,
      Tokens.semi,
      Tokens.eof,
    ];

    Lexer lexer = Lexer(input);

    for (var token in expectTokens) {
      var tok = lexer.nextToken();
      expect(tok.tokenType, token.tokenType);
      expect(tok.literal, token.literal);
    }
  });
}
