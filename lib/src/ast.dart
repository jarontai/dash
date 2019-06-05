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
  Token token;
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
  Token token;
  num value;

  NumberLiteral(this.token, this.value);

  @override
  String get tokenLiteral => token.literal;
}

class VarStatement implements Statement {
  Token token;
  Identifier name;
  Expression value;

  VarStatement(this.token, { this.name, this.value });

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
  Token token;
  Identifier name;
  Expression value;

  ReturnStatement(this.token, { this.name, this.value });

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
  Token token;
  Expression expression;

  ExpressionStatement(this.token);

  @override
  String get tokenLiteral => token.literal;

  @override
  String toString() {
    return expression == null ? '' : expression.toString();
  }  
}
