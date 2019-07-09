import 'lexer.dart';

/// AST node interface.
abstract class Node {
  String get tokenLiteral;
}

abstract class Statement extends Node {}

abstract class Expression extends Node {}

class Program implements Node {
  List<Statement> _statements = [];
  List<Statement> get statements => _statements;

  Program();

  addStatement(Statement stmt) {
    _statements.add(stmt);
  }

  @override
  String get tokenLiteral {
    if (_statements.isNotEmpty) {
      return _statements.first.tokenLiteral;
    } else {
      return '';
    }
  }

  String toString() {
    var sb = StringBuffer();
    _statements.forEach(sb.write);
    return sb.toString();
  }
}

class Identifier implements Expression {
  final Token token;
  String get value => token.literal;

  Identifier(this.token);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    return value;
  }
}

class NumberLiteral implements Expression {
  final Token token;
  num value;

  NumberLiteral(this.token, this.value);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    return value.toString();
  }
}

class StringLiteral implements Expression {
  final Token token;
  String value;

  StringLiteral(this.token, this.value);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    return value.toString();
  }
}

class BooleanLiteral implements Expression {
  final Token token;
  bool value;

  BooleanLiteral(this.token, this.value);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    return value.toString();
  }
}

class VarStatement implements Statement {
  final Token token;
  Identifier name;
  Expression value;

  VarStatement(this.token, {this.name, this.value});

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    var sb = StringBuffer();
    sb..write(tokenLiteral)..write(' ')..write(name)..write(" = ");
    if (value != null) {
      sb.write(value);
    }
    sb.write(';');
    return sb.toString();
  }
}

class ReturnStatement implements Statement {
  final Token token;
  Identifier name;
  Expression value;

  ReturnStatement(this.token, {this.name, this.value});

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    var sb = StringBuffer();
    sb..write(tokenLiteral)..write(' ');
    if (value != null) {
      sb.write(value);
    }
    sb.write(';');
    return sb.toString();
  }
}

class ExpressionStatement implements Statement {
  final Token token;
  Expression expression;

  ExpressionStatement(this.token);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    return expression == null ? '' : expression.toString();
  }
}

class PrefixExpression implements Expression {
  final Token token;
  String op;
  Expression right;

  PrefixExpression(this.token, this.op);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    return '($op$right)';
  }
}

class InfixExpression implements Expression {
  final Token token;
  String op;
  Expression right;
  Expression left;

  InfixExpression(this.token, this.op, this.left);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    return '($left $op $right)';
  }
}

class BlockStatement implements Statement {
  final Token token;
  List<Statement> statements = [];

  BlockStatement(this.token);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    var result = StringBuffer();
    result.writeAll(statements);
    return result.toString();
  }
}

class IfExpression implements Expression {
  final Token token;
  Expression condition;
  BlockStatement consequence;
  BlockStatement alternative;

  IfExpression(this.token);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    return 'if $condition $consequence ${alternative == null ? '' : alternative}';
  }
}

class FunctionLiteral implements Expression {
  final Token token;
  final List<Identifier> parameters = [];
  BlockStatement body;

  FunctionLiteral(this.token);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    var result = StringBuffer();
    result..write('(')..write(parameters.join(', '))..write(')')..write(body);
    return result.toString();
  }
}

class CallExpression implements Expression {
  final Token token;
  Expression function;
  List<Expression> arguments;

  CallExpression(this.token, this.function);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    var result = StringBuffer();
    result..write(function)..write('(')..write(arguments.join(', '))..write(')');
    return result.toString();
  }
}