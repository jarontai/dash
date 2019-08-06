import '../parser/ast.dart';
import '../runner.dart';
import '../scanner/scanner.dart';
import 'interpreter.dart';

class Resolver implements ExpressionVisitor<void>, StatementVisitor<void> {
  final Interpreter _interpreter;
  final List<Map<String, bool>> _scopes = [];
  FunctionType _currentFunction = FunctionType.NONE;
  ClassType _currentClass = ClassType.NONE;

  Resolver(this._interpreter);

  void resolveStatementList(List<Statement> statements) {
    for (var stmt in statements) {
      _resolveStatement(stmt);
    }
  }

  @override
  void visitAssignExpression(AssignExpression expression) {
    _resolveExpression(expression.value);
    _resolveLocal(expression, expression.name);
  }

  @override
  void visitBinaryExpression(BinaryExpression expression) {
    _resolveExpression(expression.left);
    _resolveExpression(expression.right);
  }

  @override
  void visitBlockStatement(BlockStatement statement) {
    _beginScope();
    resolveStatementList(statement.statements);
    _endScope();
  }

  @override
  void visitCallExpression(CallExpression expression) {
    _resolveExpression(expression.callee);
    expression.arguments.forEach((arg) {
      _resolveExpression(arg);
    });
  }

  @override
  void visitClassStatement(ClassStatement statement) {
    var enclosingClass = _currentClass;
    _currentClass = ClassType.CLASS;

    _declare(statement.name);
    _define(statement.name);

    if (statement.superclass != null &&
        statement.name.lexeme == (statement.superclass.name.lexeme)) {
      Runner.reportTokenError(
          statement.superclass.name, 'A class cannot inherit from itself.');
    }

    if (statement.superclass != null) {
      _currentClass = ClassType.SUBCLASS;
      _resolveExpression(statement.superclass);
    }

    if (statement.superclass != null) {
      _beginScope();
      _scopes.first['super'] = true;
    }

    _beginScope();
    _scopes.first['this'] = true;

    statement.methods.forEach((method) {
      var declaration = FunctionType.METHOD;
      _resolveFunction(method, declaration);
    });

    _endScope();

    if (statement.superclass != null) {
      _endScope();
    }

    _currentClass = enclosingClass;
  }

  @override
  void visitExpressionStatement(ExpressionStatement statement) {
    _resolveExpression(statement.expression);
  }

  @override
  void visitFunctionStatement(FunctionStatement statement) {
    _declare(statement.name);
    _define(statement.name);
    _resolveFunction(statement, FunctionType.FUNCTION);
  }

  @override
  void visitGetExpression(GetExpression expression) {
    _resolveExpression(expression.object);
  }

  @override
  void visitGroupingExpression(GroupingExpression expression) {
    _resolveExpression(expression.expression);
  }

  @override
  void visitIfStatement(IfStatement statement) {
    _resolveExpression(statement.condition);
    _resolveStatement(statement.thenBranch);
    if (statement.elseBranch != null) {
      _resolveStatement(statement.elseBranch);
    }
  }

  @override
  void visitLiteralExpression(LiteralExpression expression) {}

  @override
  void visitLogicalExpression(LogicalExpression expression) {
    _resolveExpression(expression.left);
    _resolveExpression(expression.right);
  }

  @override
  void visitReturnStatement(ReturnStatement statement) {
    if (_currentFunction == FunctionType.NONE) {
      Runner.reportTokenError(
          statement.keyword, 'Cannot return from top-level code.');
    }

    if (statement.value != null) {
      _resolveExpression(statement.value);
    }
  }

  @override
  void visitSetExpression(SetExpression expression) {
    _resolveExpression(expression.value);
    _resolveExpression(expression.object);
  }

  @override
  void visitSuperExpression(SuperExpression expression) {
    if (_currentClass == ClassType.NONE) {
      Runner.reportTokenError(
          expression.keyword, "Cannot use 'super' outside of a class.");
    } else if (_currentClass != ClassType.SUBCLASS) {
      Runner.reportTokenError(expression.keyword,
          "Cannot use 'super' in a class with no superclass.");
    }

    _resolveLocal(expression, expression.keyword);
  }

  @override
  void visitThisExpression(ThisExpression expression) {
    if (_currentClass == ClassType.NONE) {
      Runner.reportTokenError(
          expression.keyword, 'Cannot use \'this\' outside of a class.');
      return;
    }
    _resolveLocal(expression, expression.keyword);
  }

  @override
  void visitUnaryExpression(UnaryExpression expression) {
    _resolveExpression(expression.right);
  }

  @override
  void visitVariableExpression(VariableExpression expression) {
    if (_scopes.isNotEmpty && _scopes.first[expression.name.lexeme] == false) {
      Runner.reportTokenError(
          expression.name, 'Cannot read local varialbe in its own initializer');
    }

    _resolveLocal(expression, expression.name);
  }

  @override
  void visitVarStatement(VarStatement statement) {
    _declare(statement.name);
    if (statement.initializer != null) {
      _resolveExpression(statement.initializer);
    }
    _define(statement.name);
  }

  @override
  void visitWhileStatement(WhileStatement statement) {
    _resolveExpression(statement.condition);
    _resolveStatement(statement.body);
  }

  void _beginScope() {
    _scopes.insert(0, {});
  }

  void _declare(Token name) {
    if (_scopes.isEmpty) return;
    if (_scopes.first.containsKey(name.lexeme)) {
      Runner.reportTokenError(
          name, 'Variable with this name already declared in this scope.');
    }

    _scopes.first[name.lexeme] = false;
  }

  void _define(Token name) {
    if (_scopes.isEmpty) return;
    _scopes.first[name.lexeme] = true;
  }

  void _endScope() {
    _scopes.removeAt(0);
  }

  void _resolveExpression(Expression expr) {
    expr.acceptExpression(this);
  }

  void _resolveFunction(FunctionStatement statement, FunctionType type) {
    var enclosingFunction = _currentFunction;
    _currentFunction = type;

    _beginScope();
    statement.params.forEach((param) {
      _declare(param);
      _define(param);
    });
    resolveStatementList(statement.body);
    _endScope();

    _currentFunction = enclosingFunction;
  }

  void _resolveLocal(Expression expression, Token name) {
    for (var i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes[i].containsKey(name.lexeme)) {
        var distance = _scopes.length - 1 - i;
        _interpreter.resolve(expression, distance);
        return;
      }
    }
  }

  void _resolveStatement(Statement stmt) {
    stmt.acceptStatement(this);
  }
}

enum ClassType {
  NONE,
  CLASS,
  SUBCLASS,
}

enum FunctionType {
  NONE,
  FUNCTION,
  METHOD,
}
