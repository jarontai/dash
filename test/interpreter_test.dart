import 'package:dash/dash.dart';
import 'package:test/test.dart';

void main() {
  test('basic expressions', () {
    var inputs = [
      '1;',
      '2;',
      '"string";',
      'false;',
      'true;',
      '1 + 2;',
      '1 + 2 / 1 + 3;',
      '1 + 2 / (1 + 3);',
      '1 > 2;',
      '1 < 2;',
      '1 <= 2;',
      '1 >= 2;',
    ];

    var expects = [
      1,
      2,
      'string',
      false,
      true,
      3,
      6,
      1.5,
      false,
      true,
      true,
      false,
    ];

    var interpreter = Interpreter();
    for (var i = 0; i < inputs.length; i++) {
      var tokens = Scanner(inputs[i]).scanTokens();
      var stmts = Parser(tokens).parse();
      expect(interpreter.interpreter(stmts), expects[i]);
    }
  });

  test('var statements', () {
    var inputs = [
      'var one = 1;',
      'var two = 2;',
      'var string = "string";',
    ];

    var expects = [
      1,
      2,
      'string',
    ];

    var interpreter = Interpreter();
    for (var i = 0; i < inputs.length; i++) {
      var tokens = Scanner(inputs[i]).scanTokens();
      var stmts = Parser(tokens).parse();
      var result = interpreter.interpreter(stmts);
      expect(result, expects[i]);
    }
  });
}
