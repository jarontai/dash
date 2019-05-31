import 'dart:io';

import 'package:dash/src/lexer.dart';

/// Dash's repl (Read Eval Print Loop).
class Repl {
  String _prompt = '>> ';

  run() {
    stdout.write(_prompt);
    var input = stdin.readLineSync();
    while (input != null) {
      var lexer = Lexer(input);

      for (var token = lexer.nextToken(); token.tokenType != TokenType.EOF; token = lexer.nextToken()) {
        // TODO:
        print(token);
      }

      stdout.write(_prompt);
      input = stdin.readLineSync();
    }
  }
}