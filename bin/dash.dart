import 'package:dash/dash.dart';

main(List<String> args) {
  if (args.length > 1) {
    print("Usage: dash [script]");
  } else if (args.length == 1) {
    Dash.runFile(args[0]);
  } else {
    Dash.runPrompt();
  }
}