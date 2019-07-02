import 'package:dash/dash.dart';
import 'package:dash/src/object.dart';
import 'package:test/test.dart';

void main() {
  test('number', () {
    var inputs = ['5', '10', '2.5'];
    var expects = [5, 10, 2.5];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(obj, isA<Number>());
      expect((obj as Number).value, expects[i]);
    }
  });

  test('bollean', () {
    var inputs = ['true', 'false'];
    var expects = [true, false];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(obj, isA<Boolean>());
      expect((obj as Boolean).value, expects[i]);
    }
  });

  test('bang', () {
    var inputs = ['!true', '!false', '!!true', '!!false'];
    var expects = [false, true, true, false];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(obj, isA<Boolean>());
      expect((obj as Boolean).value, expects[i]);
    }
  });

  test('minus prefix', () {
    var inputs = ['5', '10', '-5', '-10'];
    var expects = [5, 10, -5, -10];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(obj, isA<Number>());
      expect((obj as Number).value, expects[i]);
    }
  });

  test('number infix', () {
    var inputs = ['5', '10', '5-5', '5+10-5', '3*5', '10-3*5', '50/10+5*2'];
    var expects = [5, 10, 0, 10, 15, -5, 15];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(obj, isA<Number>());
      expect((obj as Number).value, expects[i]);
    }
  });

  test('boolean operators', () {
    var inputs = [
      'true',
      'false',
      '5<10',
      '5>10',
      '5<=10',
      '5<=5',
      '5>=5',
      '5>=10',
      'true==true',
      'false==true',
      '(5<10)==true',
      '(5>=10)!=false',
    ];
    var expects = [
      true,
      false,
      true,
      false,
      true,
      true,
      true,
      false,
      true,
      false,
      true,
      false
    ];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(obj, isA<Boolean>());
      expect((obj as Boolean).value, expects[i]);
    }
  });

  test('if else', () {
    var inputs = [
      'if (true) { 10 }',
      'if (false) { 10 }',
      'if (1) { 10 }',
      'if (1) { 10 } else { 20 }',
      'if (1 < 2) { 10 }',
      'if (1 > 2) { 10 }',
      'if (1 < 2) { 10 } else { 20 }',
      'if (1 > 2) { 10 } else { 20 }',
    ];
    var expects = [
      10,
      null,
      null,
      20,
      10,
      null,
      10,
      20
    ];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(((obj is Number) || (obj is Null)), true);
      if (obj is Number) {
        expect(obj.value, expects[i]);
      } else if (obj is Null) {
        expect(null, expects[i]);
      }
    }
  });

  test('return', () {
    var inputs = [
      'return 10;',
      'return 10; 5;',
      'return 2 * 5; 5;',
      '1; return 2 * 5; 5;',
      'if (5 < 10) { return 10; }',
      'if (5 > 10) { return 5; } else { return 10; }',
      'if (5 > 10) { return 5; } else { if (5 < 10) { return 10; } return 1; }',
    ];
    var expects = [
      10,
      10,
      10,
      10,
      10,
      10,
      10,
    ];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(((obj is Number) || (obj is Null)), true);
      if (obj is Number) {
        expect(obj.value, expects[i]);
      } else if (obj is Null) {
        expect(null, expects[i]);
      }
    }
  });

  test('error handling', () {
    var inputs =[
      '5 + true;',
      '-true;',
      'true + false;',
      'if (1 < 10) { true + false; }',
      'if (1 > 10) { return 1; } else { return true + false; }',
      'if (1 > 10) { return 1; } else { if (1 < 10) { return true + false; } return 1;}',
      'foobar',
    ];

    var expects = [
      'type mismatch: NUMBER + BOOLEAN',
      'unknown operator: -BOOLEAN',
      'unknown operator: BOOLEAN + BOOLEAN',
      'unknown operator: BOOLEAN + BOOLEAN',
      'unknown operator: BOOLEAN + BOOLEAN',
      'unknown operator: BOOLEAN + BOOLEAN',
      'identifier not found: foobar',
    ];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(obj, isA<ErrorObject>());
      expect((obj as ErrorObject).message, expects[i]);
    }
  });

  test('var binding', () {
    var inputs = [
      'var a = 10; a;',
      'var a = 10; a * a;',
      'var a = 10; var b = a; b;',
      'var a = 10; var b = a; var c = a + b + 10; c;',
    ];
    var expects = [
      10,
      100,
      10,
      30,
    ];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(obj, isA<Number>());
      expect((obj as Number).value, expects[i]);
    }
  });

  test('function', () {
    var inputs = [
      'var fn = (x) { return x; }; fn(10);',
      'var fn = (x) { return x + x; }; fn(10);',
      'var fn = (x, y) { return x + y; }; fn(10, 20);',
      'var fn = (x) { return x + 10; }; fn(10);',
      'var fn = (x, y) { return x + y; }; fn(10, fn(10, 10));',

    ];
    var expects = [
      10,
      20,
      30,
      20,
      30
    ];

    Evaluator evaluator = Evaluator();
    for (var i = 0; i < inputs.length; i++) {
      Lexer lexer = Lexer(inputs[i]);
      Parser parser = Parser(lexer);
      Program program = parser.parseProgram();

      var obj = evaluator.evalWithEnv(program);
      expect(obj, isA<Number>());
      expect((obj as Number).value, expects[i]);
    }
  });
}
