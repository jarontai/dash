import '../runner.dart';
import '../parser/ast.dart';
import '../scanner/scanner.dart';
import 'environment.dart';

// Dash's interpreter, which response for evaluating ast [Expression]s.
class Interpreter
    implements ExpressionVisitor<Object>, StatementVisitor<Object> {
  Environment _environment = Environment();

  Object interpreter(List<Statement> statements) {
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
    return _executeBlock(statement.statements, Environment(_environment));
  }

  Object _executeBlock(List<Statement> statements, Environment environment) {
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