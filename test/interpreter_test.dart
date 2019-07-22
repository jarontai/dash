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

  test('assign statements', () {
    var inputs = [
      'var one = 1; one = 2;',
      'var string = "string"; string = "hello";',
    ];

    var expects = [2, 'hello'];

    var interpreter = Interpreter();

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var tokens = Scanner(input).scanTokens();
      var stmts = Parser(tokens).parse();
      var result = interpreter.interpreter(stmts);
      expect(result, expects[i]);
    }
  });

  test('block statements', () {
    var inputs = [
      '{ var one = 1; one = 2; } ',
      '{ var string = "string"; string = "hello"; }',
      '{ var one = 1; one = 2; } var one = 3;',
      'var one = 1; var string = "hi"; { var string = "string"; string = "hello"; } string = "what";',
    ];

    var expects = [2, 'hello', 3, 'what'];

    var interpreter = Interpreter();

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var tokens = Scanner(input).scanTokens();
      var stmts = Parser(tokens).parse();
      var result = interpreter.interpreter(stmts);
      expect(result, expects[i]);
    }
  });

  test('if statements', () {
    var inputs = [
      'var one = 1; if (one >= 1) { one = 2; } else { one = 3; }',
      'var one = 1; if (one < 1) { one = 2; } else { one = 3; }',
    ];

    var expects = [2, 3];

    var interpreter = Interpreter();

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var tokens = Scanner(input).scanTokens();
      var stmts = Parser(tokens).parse();
      var result = interpreter.interpreter(stmts);
      expect(result, expects[i]);
    }
  });

  test('logical', () {
    var inputs = [
      'var one = 1; if (one < 1 && false) { one = 2; } else { one = 3; }',
      'var one = 1; if (one >= 1 && true) { one = 2; } else { one = 3; }',
    ];

    var expects = [3, 2];

    var interpreter = Interpreter();

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var tokens = Scanner(input).scanTokens();
      var stmts = Parser(tokens).parse();
      var result = interpreter.interpreter(stmts);
      expect(result, expects[i]);
    }
  });
}
