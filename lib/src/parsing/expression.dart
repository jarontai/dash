import '../scanning/token.dart';

abstract class Expression {
  R accept<R>(Visitor<R> visitor);
}

class BinaryExpression extends Expression {
  final Expression left;
  final Token op;
  final Expression right;
  BinaryExpression(this.left, this.op, this.right);

  R accept<R>(Visitor<R> visitor) {
    return visitor.visitBinaryExpression(this);
  }
}

class GroupingExpression extends Expression {
  final Expression expression;
  GroupingExpression(this.expression);

  R accept<R>(Visitor<R> visitor) {
    return visitor.visitGroupingExpression(this);
  }
}

class LiteralExpression extends Expression {
  final Object value;
  LiteralExpression(this.value);

  R accept<R>(Visitor<R> visitor) {
    return visitor.visitLiteralExpression(this);
  }
}

class UnaryExpression extends Expression {
  final Token op;
  final Expression right;
  UnaryExpression(this.op, this.right);

  R accept<R>(Visitor<R> visitor) {
    return visitor.visitUnaryExpression(this);
  }
}

abstract class Visitor<R> {
  R visitBinaryExpression(BinaryExpression expression);
  R visitGroupingExpression(GroupingExpression expression);
  R visitLiteralExpression(LiteralExpression expression);
  R visitUnaryExpression(UnaryExpression expression);
}
