enum ObjectType {
  NUMBER,
  BOOLEAN,
  NULL
}

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

  @override
  String toString() {
    return value.toString();
  }
}

class Null implements EvalObject {
  ObjectType get type => ObjectType.NULL;

  @override
  String toString() {
    return 'null';
  }  
}
