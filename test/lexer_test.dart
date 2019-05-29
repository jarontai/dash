import 'package:dash/dash.dart';
import 'package:test/test.dart';

void main() {
  test('basic 1', () {
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

  test('basic 2', () {
    // var input = '''var five = 5;
    //   var ten = 10;

    //   var add = (x, y) {
    //     x + y;
    //   };

    //   var result = add(five, ten);''';

    // var expectTokens = [
    //   Tokens.assign,
    //   Tokens.plus,
    //   Tokens.lparen,
    //   Tokens.rparen,
    //   Tokens.lbrace,
    //   Tokens.rbrace,
    //   Tokens.comma,
    //   Tokens.semi,
    //   Tokens.eof,
    // ];

    // Lexer lexer = Lexer(input);

    // for (var token in expectTokens) {
    //   var tok = lexer.nextToken();
    //   expect(tok.tokenType, token.tokenType);
    //   expect(tok.literal, token.literal);
    // }
  });
}
