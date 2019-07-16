import '../runner.dart';
import '../parsing/ast.dart';
import '../scanning/scanner.dart';

// Dash's interpreter, which response for evaluating ast [Expression]s.
class Interpreter implements Visitor<Object> {
  Object interpreter(Expression expression) {
    Object value;
    try {
      value = _evaluate(expression);
    } on RuntimeError catch (e) {
      Runner.runtimeError(e);
    }
    
    // Hack, remove '.0' from integer-value doubles
    if (value is double && value.toString().endsWith('.0')) {
      value = int.parse(value.toString().substring(0, value.toString().length - 2));
    }

    return value;
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
    return expression.accept(this);
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
