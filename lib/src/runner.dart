import 'dart:io';

import 'scanner/scanner.dart';
import 'parser/parser.dart';
import 'interpreter/interpreter.dart';

// The dash runner
class Runner {
  static bool hadError = false;
  static bool hadRuntimeError = false;
  static final Interpreter interpreter = Interpreter();

  static void runFile(String arg) {
    var file = File(arg);
    if (file.existsSync()) {
      run(file.readAsStringSync());

      if (hadError) {
        exit(65);
      }
      if (hadRuntimeError) {
        exit(70);
      }
    }
  }

  static void runPrompt() {
    for (;;) {
      stdout.write('> ');
      run(stdin.readLineSync());
      hadError = false;
    }
  }

  static Object run(String source, [bool doPrint = true]) {
    var scanner = Scanner(source);
    var tokens = scanner.scanTokens();
    var parser = Parser(tokens);
    var stmts = parser.parse();

    if (hadError) return null;

    var result = interpreter.interprete(stmts);
    if (doPrint) {
      stdout.writeln(result.toString());
    }
    return result;
  }

  static void error(int line, String message) {
    _report(line, '', message);
  }

  static void _report(int line, String where, String message) {
    stdout.writeln('[line $line] Error $where: $message');
    hadError = true;
  }

  static void parseError(ParseError error) {
    var token = error.token;
    var message = error.message;
    if (token.type == TokenType.EOF) {
      _report(token.line, 'at end', message);
    } else {
      _report(token.line, 'at \'${token.lexeme}\'', message);
    }
  }

  static void runtimeError(RuntimeError error) {
    stdout.writeln('[line ${error.token.line}] Runtime Error: ${error.message}');
    hadRuntimeError = true;
  }
}
