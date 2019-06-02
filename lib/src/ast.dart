import 'lexer.dart';

/// AST node interface, all the nodes must implement 
abstract class Node {
  String get tokenLiteral;
}

abstract class Statement extends Node {}

abstract class Expression extends Node {}

class Program implements Node {
  List<Statement> _statements;
  List<Statement> get statements => _statements;

  Program() {
    _statements = <Statement>[];
  }

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
}

class VarStatement implements Statement {
  Token token;
  Identifier name;
  Expression value;

  VarStatement(this.token) {}

  @override
  // TODO: implement tokenLiteral
  String get tokenLiteral => null;  
}

class Identifier implements Expression {
  Token token;
  String get value => token.literal;

  Identifier(this.token);

  @override
  String get tokenLiteral => token.literal;
  
}