import 'dart:io';

import 'scanning/scanner.dart';
import 'parsing/ast_printer.dart';
import 'parsing/parser.dart';

// The dash runner
class Runner {
  static bool hadError = false;

  static void runFile(String arg) {
    var file = File(arg);
    if (file.existsSync()) {
      run(file.readAsStringSync());

      if (hadError) {
        exit(65);
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

  static String run(String source) {
    var scanner = Scanner(source);
    var tokens = scanner.scanTokens();
    var parser = Parser(tokens);
    var expr = parser.parse();

    if (hadError) return null;

    var result = AstPrinter().print(expr);
    stdout.writeln(result);
    return result;
  }

  static void error(int line, String message) {
    _report(line, '', message);
  }

  static void _report(int line, String where, String message) {
    print('[line $line] Error $where: $message');
    hadError = true;
  }

  static void parseError(Token token, String message) {
    if (token.type == TokenType.EOF) {
      _report(token.line, ' at end', message);
    } else {
      _report(token.line, ' at \'${token.lexeme}\'', message);
    }
  }
}
