import '../parser/ast.dart';
import 'environment.dart';
import 'interpreter.dart';

// Base interface for all functions
abstract class Callable {
  int get arity;
  Object call(Interpreter interpreter, List<Object> arguments);
}

class DashFunction implements Callable {
  FunctionStatement declaration;
  Environment closure;

  DashFunction(this.declaration, this.closure);

  @override
  int get arity => declaration.params.length;

  @override
  Object call(Interpreter interpreter, List<Object> arguments) {
    var environment = Environment.enclosing(closure);
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
  String toString() {
    return '<function ${declaration.name.lexeme}>';
  }
}

class NativePrintFunction implements Callable {
  @override
  int get arity => 1;

  @override
  Object call(Interpreter interpreter, List<Object> arguments) {
    var arg = arguments.first;
    print(arg);
    return null;
  }

  @override
  String toString() {
    return '<native function>';
  }
}
