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

      var obj = evaluator.eval(program);
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

      var obj = evaluator.eval(program);
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

      var obj = evaluator.eval(program);
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

      var obj = evaluator.eval(program);
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

      var obj = evaluator.eval(program);
      expect(obj, isA<Number>());
      expect((obj as Number).value, expects[i]);
    }
  });
}
