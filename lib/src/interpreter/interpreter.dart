import '../runner.dart';
import '../parser/ast.dart';
import '../scanner/scanner.dart';
import 'environment.dart';
import 'callable.dart';

// Dash's interpreter, which response for evaluating ast [Expression]s.
class Interpreter
    implements ExpressionVisitor<Object>, StatementVisitor<Object> {
  Environment globals;
  Environment _environment;

  Interpreter() {
    globals = Environment();
    _environment = globals;

    globals.define('print', NativePrintFunction());
  }

  Object interprete(List<Statement> statements) {
    var result;
    try {
      for (var stmt in statements) {
        result = _execute(stmt);
      }
    } on RuntimeError catch (e) {
      Runner.runtimeError(e);
    }
    return result;
  }

  Object _execute(Statement stmt) {
    return stmt.acceptStatement(this);
  }

  @override
  Object visitBinaryExpression(BinaryExpression expression) {
    var right = _evaluate(expression.right);
    var left = _evaluate(expression.left);
    switch (expression.op.type) {
      case TokenType.MINUS:
        _checkNumberOperand(expression.op, right, null);
        return (left as num) - (right as num);
        break;
      case TokenType.PLUS:
        if (left is num && right is num) {
          return left + right;
        } else if (left is String && right is String) {
          return left + right;
        }
        throw RuntimeError(
            expression.op, 'Operands must be two numbers or two strings.');
        break;
      case TokenType.SLASH:
        _checkNumberOperand(expression.op, right, left);
        return (left as num) / (right as num);
        break;
      case TokenType.STAR:
        _checkNumberOperand(expression.op, right, left);
        return (left as num) * (right as num);
        break;
      case TokenType.GREATER:
        _checkNumberOperand(expression.op, right, left);
        return (left as num) > (right as num);
        break;
      case TokenType.GREATER_EQUAL:
        _checkNumberOperand(expression.op, right, left);
        return (left as num) >= (right as num);
        break;
      case TokenType.LESS:
        _checkNumberOperand(expression.op, right, left);
        return (left as num) < (right as num);
        break;
      case TokenType.LESS_EQUAL:
        _checkNumberOperand(expression.op, right, left);
        return (left as num) <= (right as num);
        break;
      case TokenType.BANG_EQUAL:
        return left != right;
        break;
      case TokenType.EQUAL_EQUAL:
        return left == right;
        break;
      case TokenType.AND:
        return left && right;
        break;
      case TokenType.OR:
        return left || right;
        break;
      default:
        break;
    }
    return null;
  }

  @override
  Object visitGroupingExpression(GroupingExpression expression) {
    return _evaluate(expression.expression);
  }

  @override
  Object visitLiteralExpression(LiteralExpression expression) {
    return expression.value;
  }

  @override
  Object visitUnaryExpression(UnaryExpression expression) {
    var right = _evaluate(expression.right);
    switch (expression.op.type) {
      case TokenType.MINUS:
        return -(right as num);
        break;
      case TokenType.BANG:
        return !_isTruthy(right);
        break;
      default:
        break;
    }
    return null;
  }

  Object _evaluate(Expression expression) {
    return expression.acceptExpression(this);
  }

  bool _isTruthy(Object right) {
    if (right == null) return false;
    if (right is bool) {
      return right;
    }
    return false;
  }

  void _checkNumberOperand(Token token, Object right, [Object left]) {
    if (left == null) {
      if (right is num) return;
      throw RuntimeError(token, 'Operand must be a number.');
    }

    if (left is num && right is num) return;
    throw RuntimeError(token, 'Operands must be numbers.');
  }

  @override
  Object visitExpressionStatement(ExpressionStatement statement) {
    return _evaluate(statement.expression);
  }

  @override
  Object visitVarStatement(VarStatement stmt) {
    var result;
    if (stmt.initializer != null) {
      result = _evaluate(stmt.initializer);
    }
    _environment.define(stmt.name.lexeme, result);
    return result;
  }

  @override
  Object visitVariableExpression(VariableExpression expression) {
    return _environment.fetch(expression.name);
  }

  @override
  Object visitAssignExpression(AssignExpression expression) {
    Object value = _evaluate(expression.value);
    _environment.assign(expression.name, value);
    return value;
  }

  @override
  Object visitBlockStatement(BlockStatement statement) {
    return executeBlock(statement.statements, Environment(_environment));
  }

  Object executeBlock(List<Statement> statements, Environment environment) {
    var previous = _environment;

    var result;
    try {
      _environment = environment;
      for (var stmt in statements) {
        result = _execute(stmt);
      }
    } finally {
      _environment = previous;
    }
    return result;
  }

  @override
  Object visitIfStatement(IfStatement statement) {
    var result;
    if (_isTruthy(_evaluate(statement.condition))) {
      result = _execute(statement.thenBranch);
    } else if (statement.elseBranch != null) {
      result = _execute(statement.elseBranch);
    }
    return result;
  }

  @override
  Object visitLogicalExpression(LogicalExpression expression) {
    var left = _evaluate(expression.left);
    if (expression.op.type == TokenType.OR) {
      if (_isTruthy(left)) return left;
    } else {
      if (!_isTruthy(left)) return left;
    }
    return _evaluate(expression.right);
  }

  @override
  Object visitWhileStatement(WhileStatement statement) {
    var result;
    while (_isTruthy(_evaluate(statement.condition))) {
      result = _execute(statement.body);
    }
    return result;
  }

  @override
  Object visitCallExpression(CallExpression expression) {
    var callee = _evaluate(expression.callee);
    var arguments = expression.arguments
        .map<Object>((argument) => _evaluate(argument))
        .toList();

    if (callee is Callable) {
      if (callee.arity != arguments.length) {
        throw RuntimeError(expression.paren,
            'Expect ${callee.arity} arguments but got ${arguments.length}.');
      }
      return callee.call(this, arguments);
    } else {
      throw RuntimeError(
          expression.paren, 'Can only call function and classes.');
    }
  }

  @override
  Object visitFunctionStatement(FunctionStatement statement) {
    var function = DashFunction(statement);
    _environment.define(statement.name.lexeme, function);
    return function;
  }

  @override
  Object visitReturnStatement(ReturnStatement statement) {
    var value;
    if (statement.value != null) {
      value = _evaluate(statement.value);
    }

    throw Return(value);
  }
}

class RuntimeError extends Error {
  final Token token;
  final String message;

  RuntimeError(this.token, this.message);

  @override
  String toString() {
    return '$token: $message';
  }
}

class Return {
  final Object value;

  Return(this.value);
}
