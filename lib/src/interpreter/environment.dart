import '../scanner/token.dart';
import 'interpreter.dart';

class Environment {
  final Environment _enclosing;
  final Map<String, Object> _values = {};

  Environment() : _enclosing = null;

  Environment.enclosing(Environment enclosing) : _enclosing = enclosing;

  void assign(Token name, Object value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    if (_enclosing != null) {
      _enclosing.assign(name, value);
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

    if (_enclosing != null) {
      return _enclosing.fetch(name);
    }

    throw RuntimeError(name, 'Undefined variable ${name.lexeme}.');
  }

  // TODO: ancestor resolving is not working
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
