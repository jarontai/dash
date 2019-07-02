import 'ast.dart' as ast;

abstract class EvalObject {
  String get type;
}

class ErrorObject implements EvalObject {
  @override
  String get type => 'ERROR';

  String message;

  ErrorObject.prefix(String op, EvalObject right) {
    message = 'unknown operator: $op${right.type}';
  }

  ErrorObject.infix(String op, EvalObject left, EvalObject right,
      {bool typeMismatch = false}) {
    message =
        '${typeMismatch ? 'type mismatch' : 'unknown operator'}: ${left.type} $op ${right.type}';
  }

  ErrorObject.identifier(String value) {
    message = 'identifier not found: $value';
  }

  ErrorObject.fn(String type) {
    message = 'not a function: $type';
  }

  @override
  String toString() {
    return message;
  }
}

class Number implements EvalObject {
  String get type => 'NUMBER';

  num value;

  Number(this.value);

  @override
  String toString() {
    return value.toString();
  }
}

class Boolean implements EvalObject {
  String get type => 'BOOLEAN';

  bool value;

  static final Boolean _true = Boolean._internal(true);
  static final Boolean _false = Boolean._internal(false);

  factory Boolean(bool value) {
    return value ? _true : _false;
  }

  Boolean._internal(this.value);

  @override
  String toString() {
    return value.toString();
  }
}

class Null implements EvalObject {
  String get type => 'NULL';

  static final Null _null = Null._internal();

  factory Null() => _null;

  Null._internal();

  @override
  String toString() {
    return 'null';
  }
}

class ReturnValue implements EvalObject {
  @override
  String get type => 'RETURN';

  Object value;

  ReturnValue(this.value);

  @override
  String toString() => value.toString();
}

class FunctionObject implements EvalObject {
  final List<ast.Identifier> parameters;
  final ast.BlockStatement body;
  Environment env;

  FunctionObject(this.parameters, this.body, this.env);

  @override
  String get type => 'FUNCTION';

  @override
  String toString() {
    var result = StringBuffer();
    result..write('(')..write(parameters.join(', '))..write(')')..write(body);
    return result.toString();
  }
}

class Environment {
  final Map<String, EvalObject> _store = <String, EvalObject>{};
  final Environment _outer;

  Environment() : _outer = null;

  Environment.withOuter(this._outer);

  EvalObject fetch(Object key) {
    var result = _store[key.toString()];
    if (result == null && _outer != null) {
      result = _outer.fetch(key.toString());
    }
    return result;
  }

  void put(key, value) {
    _store[key.toString()] = value;
  }

  bool containsKey(String key) {
    if (_outer == null) {
      return _store.containsKey(key);
    }
    return _store.containsKey(key) || _outer.containsKey(key);
  }
}
