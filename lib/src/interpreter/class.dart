import '../scanner/token.dart';
import 'interpreter.dart';
import 'function.dart';

class DashClass implements Callable {
  final String name;
  final Map<String, DashFunction> methods;

  DashClass(this.name, this.methods);

  @override
  String toString() {
    return name;
  }

  @override
  int get arity => 0;

  @override
  Object call(Interpreter interpreter, List<Object> arguments) {
    var instance = DashInstance(this);
    return instance;
  }

  DashFunction findMethod(String name) => methods[name];
}

class DashInstance {
  final DashClass klass;
  final Map<String, Object> fields = {};

  DashInstance(this.klass);

  Object fetch(Token name) {
    if (fields.containsKey(name.lexeme)) {
      return fields[name.lexeme];
    }

    var method = klass.findMethod(name.lexeme);
    if (method != null) return method.bind(this);

    throw RuntimeError(name, 'Undefined property ${name.lexeme}.');
  }

  void assign(Token name, Object value) {
    fields[name.lexeme] = value;
  }

  @override
  String toString() {
    return '$klass instance';
  }
}
