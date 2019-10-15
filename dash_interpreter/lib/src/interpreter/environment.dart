import '../scanner/token.dart';
import 'interpreter.dart';

/// The class for storing variable bindings.
class Environment {
  final Environment enclosing;
  final Map<String, Object> _values = {};

  Environment() : enclosing = null;

  Environment.enclose(Environment enclosing) : this.enclosing = enclosing;

  void assign(Token name, Object value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    if (enclosing != null) {
      enclosing.assign(name, value);
      return;
    }

    throw RuntimeError(name, 'Undefined variable ${name.lexeme}.');
  }

  void define(String name, Object value) {
    _values[name] = value;
  }

  Object fetch(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    if (enclosing != null) {
      return enclosing.fetch(name);
    }

    throw RuntimeError(name, 'Undefined variable ${name.lexeme}.');
  }

  Object fetchByName(String name) {
    return _values[name] ?? enclosing.fetchByName(name);
  }

  // TODO: ancestor is not working
  // void assignAt(int distance, Token name, Object value) {
  //   var env = _ancestor(distance);
  //   env._values[name.lexeme] = value;
  // }

  // Object fetchAt(int distance, String lexeme) {
  //   var env = _ancestor(distance);
  //   return env._values[lexeme];
  // }

  // Environment _ancestor(int distance) {
  //   var env = this;
  //   for (var i = 0; i < distance; i++) {
  //     env = env._enclosing;
  //   }
  //   return env;
  // }
}
