import 'package:dash/src/interpreter/environment.dart';

import 'interpreter.dart';
import '../parser/ast.dart';

// Base interface for all functions
abstract class Callable {
  int get arity;
  Object call(Interpreter interpreter, List<Object> arguments);
}

class NativePrintFunction implements Callable {
  @override
  Object call(Interpreter interpreter, List<Object> arguments) {
    var arg = arguments.first;
    print(arg);
    return arg;
  }

  @override
  int get arity => 1;

  @override
  String toString() {
    return '<native function>';
  }
}

class DashFunction implements Callable {
  FunctionStatement declaration;

  DashFunction(this.declaration);

  @override
  Object call(Interpreter interpreter, List<Object> arguments) {
    var environment = Environment(interpreter.globals);
    for (var i = 0; i < declaration.params.length; i++) {
      environment.define(declaration.params[i].lexeme, arguments[i]);
    }
    
    var result;
    try {
      result = interpreter.executeBlock(declaration.body, environment);
    } on Return catch (returnValue) {
      result = returnValue.value;
    }
    return result;
  }

  @override
  int get arity => declaration.params.length;

  @override
  String toString() {
    return '<function ${declaration.name.lexeme}>';
  }
}
