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

}
