// TODO: remove?
enum ObjectType { NUMBER, BOOLEAN, NULL }

abstract class EvalObject {
  ObjectType get type;
}

class Number implements EvalObject {
  ObjectType get type => ObjectType.NUMBER;

  num value;

  Number(this.value);

  @override
  String toString() {
    return value.toString();
  }
}

class Boolean implements EvalObject {
  ObjectType get type => ObjectType.BOOLEAN;

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
  ObjectType get type => ObjectType.NULL;

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
  // TODO: implement type
  ObjectType get type => null;

  Object value;

  ReturnValue(this.value);

  @override
  String toString() => value.toString();
}
