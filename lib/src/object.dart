import 'dart:collection';

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

  ErrorObject.infix(String op, EvalObject left, EvalObject right, {bool typeMismatch = false}) {
    message = '${typeMismatch ? 'type mismatch' : 'unknown operator'}: ${left.type} $op ${right.type}';
  }

  ErrorObject.identifier(String value) {
    message = 'identifier not found: $value';
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

class Environment extends MapBase {
  final Map<String, EvalObject> _store = {};
  
  @override
  operator [](Object key) {
    return _store[key.toString()];
  }

  @override
  void operator []=(key, value) {
    _store[key.toString()] = value;
  }

  @override
  void clear() {
    _store.clear();
  }

  @override
  Iterable get keys => _store.keys;

  @override
  remove(Object key) {
    return _store.remove(key);
  }

}