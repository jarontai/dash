import 'dart:io';

import 'lexer.dart';
import 'parser.dart';
import 'evaluator.dart';

/// Dash's repl (Read Eval Print Loop).
class Repl {
  final String _prompt = '>> ';

  run() {
    var evaluator = Evaluator();
    stdout.write(_prompt);
    var input = stdin.readLineSync();
    var env = Environment();
    while (input != null) {
      if (input == 'exit') {
        break;
      }

      var lexer = Lexer(input);
      var parser = Parser(lexer);
      var program = parser.parseProgram();
      if (parser.errors.isNotEmpty) {
        parser.errors.forEach(print);
      } else {
        var evaluated = evaluator.eval(program, env);
        if (evaluated != null) {
          stdout.writeln(evaluated);
        }
      }

      stdout.write(_prompt);
      input = stdin.readLineSync();
    }
  }
}