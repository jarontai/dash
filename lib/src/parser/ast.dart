// These code was generated by ast_gen, so please don't modify directly.

import '../scanner/token.dart';

// The ast expressions.

abstract class Expression {
  R acceptExpression<R>(ExpressionVisitor<R> visitor);
}

class AssignExpression extends Expression {
  final Token name;
  final Expression value;
  AssignExpression(this.name, this.value);

  R acceptExpression<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitAssignExpression(this);
  }
}

class BinaryExpression extends Expression {
  final Expression left;
  final Token op;
  final Expression right;
  BinaryExpression(this.left, this.op, this.right);

  R acceptExpression<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitBinaryExpression(this);
  }
}

class CallExpression extends Expression {
  final Expression callee;
  final Token paren;
  final List<Expression> arguments;
  CallExpression(this.callee, this.paren, this.arguments);

  R acceptExpression<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitCallExpression(this);
  }
}

class GroupingExpression extends Expression {
  final Expression expression;
  GroupingExpression(this.expression);

  R acceptExpression<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitGroupingExpression(this);
  }
}

class LiteralExpression extends Expression {
  final Object value;
  LiteralExpression(this.value);

  R acceptExpression<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitLiteralExpression(this);
  }
}

class LogicalExpression extends Expression {
  final Expression left;
  final Token op;
  final Expression right;
  LogicalExpression(this.left, this.op, this.right);

  R acceptExpression<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitLogicalExpression(this);
  }
}

class UnaryExpression extends Expression {
  final Token op;
  final Expression right;
  UnaryExpression(this.op, this.right);

  R acceptExpression<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitUnaryExpression(this);
  }
}

class VariableExpression extends Expression {
  final Token name;
  VariableExpression(this.name);

  R acceptExpression<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitVariableExpression(this);
  }
}

abstract class ExpressionVisitor<R> {
  R visitAssignExpression(AssignExpression expression);
  R visitBinaryExpression(BinaryExpression expression);
  R visitCallExpression(CallExpression expression);
  R visitGroupingExpression(GroupingExpression expression);
  R visitLiteralExpression(LiteralExpression expression);
  R visitLogicalExpression(LogicalExpression expression);
  R visitUnaryExpression(UnaryExpression expression);
  R visitVariableExpression(VariableExpression expression);
}

abstract class Statement {
  R acceptStatement<R>(StatementVisitor<R> visitor);
}

class BlockStatement extends Statement {
  final List<Statement> statements;
  BlockStatement(this.statements);

  R acceptStatement<R>(StatementVisitor<R> visitor) {
    return visitor.visitBlockStatement(this);
  }
}

class ExpressionStatement extends Statement {
  final Expression expression;
  ExpressionStatement(this.expression);

  R acceptStatement<R>(StatementVisitor<R> visitor) {
    return visitor.visitExpressionStatement(this);
  }
}

class IfStatement extends Statement {
  final Expression condition;
  final Statement thenBranch;
  final Statement elseBranch;
  IfStatement(this.condition, this.thenBranch, this.elseBranch);

  R acceptStatement<R>(StatementVisitor<R> visitor) {
    return visitor.visitIfStatement(this);
  }
}

class FunctionStatement extends Statement {
  final Token name;
  final List<Token> params;
  final List<Statement> body;
  FunctionStatement(this.name, this.params, this.body);

  R acceptStatement<R>(StatementVisitor<R> visitor) {
    return visitor.visitFunctionStatement(this);
  }
}

class ReturnStatement extends Statement {
  final Token keyword;
  final Expression value;
  ReturnStatement(this.keyword, this.value);

  R acceptStatement<R>(StatementVisitor<R> visitor) {
    return visitor.visitReturnStatement(this);
  }
}

class VarStatement extends Statement {
  final Token name;
  final Expression initializer;
  VarStatement(this.name, this.initializer);

  R acceptStatement<R>(StatementVisitor<R> visitor) {
    return visitor.visitVarStatement(this);
  }
}

class WhileStatement extends Statement {
  final Expression condition;
  final Statement body;
  WhileStatement(this.condition, this.body);

  R acceptStatement<R>(StatementVisitor<R> visitor) {
    return visitor.visitWhileStatement(this);
  }
}

abstract class StatementVisitor<R> {
  R visitBlockStatement(BlockStatement statement);
  R visitExpressionStatement(ExpressionStatement statement);
  R visitIfStatement(IfStatement statement);
  R visitFunctionStatement(FunctionStatement statement);
  R visitReturnStatement(ReturnStatement statement);
  R visitVarStatement(VarStatement statement);
  R visitWhileStatement(WhileStatement statement);
}
