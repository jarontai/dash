import 'dart:io';

import 'package:dash/dash.dart';

main(List<String> args) {
  if (args.length > 1) {
    print("Usage: dash [script]");
    exit(64);
  } else if (args.length == 1) {
    Dash.runFile(args[0]);
  } else {
    Dash.runPrompt();
  }
}