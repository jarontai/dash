import 'dart:io';

import 'scanner.dart';

class Dash {
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

  static void run(String source) {
    var scanner = Scanner(source);
    var tokens = scanner.scanTokens();

    for (var token in tokens) {
      stdout.writeln(token);
    }
  }

  static void error(int line, String message) {
    _handleError(line, '', message);
  }

  static void _handleError(int line, String where, String message) {
    print('[line $line] Error $where: $message');
    hadError = true;
  }
}
