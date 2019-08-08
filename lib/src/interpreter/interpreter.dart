import '../parser/ast.dart';
import '../runner.dart';
import '../scanner/scanner.dart';
import 'class.dart';
import 'environment.dart';
import 'function.dart';

export 'resolver.dart';

/// Dash's interpreter, which response for evaluating ast [Expression]s and [Statement]s.
class Interpreter
    implements ExpressionVisitor<Object>, StatementVisitor<Object> {
  Environment _globals;
  Environment _environment;
  final Map<Expression, int> _locals = {};

  Interpreter() {
    _globals = Environment();
    _environment = _globals;

    _globals.define('print', NativePrintFunction());
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

  Object interpret(List<Statement> statements) {
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

  void resolve(Expression expression, int depth) {
    _locals[expression] = depth;
  }

  @override
  Object visitAssignExpression(AssignExpression expression) {
    Object value = _evaluate(expression.value);
    var distance = _locals[expression];
    if (distance != null) {
      _environment.assign(expression.name, value);
    } else {
      _globals.assign(expression.name, value);
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
  Object visitBlockStatement(BlockStatement statement) {
    return executeBlock(
        statement.statements, Environment.enclose(_environment));
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
  Object visitClassStatement(ClassStatement statement) {
    var superclass;
    if (statement.superclass != null) {
      superclass = _evaluate(statement.superclass);
      if (superclass is! DashClass) {
        throw RuntimeError(
            statement.superclass.name, 'Superclass must be a class.');
      }
    }

    _environment.define(statement.name.lexeme, null);

    if (statement.superclass != null) {
      _environment = Environment.enclose(_environment);
      _environment.define("super", superclass);
    }

    var methods = <String, DashFunction>{};
    statement.methods.forEach((method) {
      methods[method.name.lexeme] = DashFunction(method, _environment);
    });

    var klass = DashClass(statement.name.lexeme, superclass, methods);

    if (superclass != null) {
      _environment = _environment.enclosing;
    }

    _environment.assign(statement.name, klass);
    return null;
  }

  @override
  Object visitExpressionStatement(ExpressionStatement statement) {
    return _evaluate(statement.expression);
  }

  @override
  Object visitFunctionStatement(FunctionStatement statement) {
    var function = DashFunction(statement, _environment);
    _environment.define(statement.name.lexeme, function);
    return function;
  }

  @override
  Object visitGetExpression(GetExpression expression) {
    var object = _evaluate(expression.object);
    if (object is DashInstance) {
      return object.fetch(expression.name);
    }
    throw RuntimeError(expression.name, "Only instances have properties.");
  }

  @override
  Object visitGroupingExpression(GroupingExpression expression) {
    return _evaluate(expression.expression);
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
  Object visitLiteralExpression(LiteralExpression expression) {
    return expression.value;
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
  Object visitReturnStatement(ReturnStatement statement) {
    var value;
    if (statement.value != null) {
      value = _evaluate(statement.value);
    }

    throw Return(value);
  }

  @override
  Object visitSetExpression(SetExpression expression) {
    var obj = _evaluate(expression.object);
    if (obj is! DashInstance) {
      throw RuntimeError(expression.name, 'Only instances have fields.');
    }

    var value = _evaluate(expression.value);
    (obj as DashInstance).assign(expression.name, value);
    return value;
  }

  @override
  Object visitSuperExpression(SuperExpression expression) {
    var superclass = _environment.fetchByName('super') as DashClass;
    var object = _environment.fetchByName('this') as DashInstance;
    var method = superclass.findMethod(expression.method.lexeme);

    if (method == null) {
      throw RuntimeError(expression.method,
          "Undefined property '" + expression.method.lexeme + "'.");
    }
    return method.bind(object);
  }

  @override
  Object visitThisExpression(ThisExpression expression) {
    return _lookupVariable(expression.keyword, expression);
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

  @override
  Object visitVariableExpression(VariableExpression expression) {
    return _lookupVariable(expression.name, expression);
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
  Object visitWhileStatement(WhileStatement statement) {
    var result;
    while (_isTruthy(_evaluate(statement.condition))) {
      result = _execute(statement.body);
    }
    return result;
  }

  void _checkNumberOperand(Token token, Object right, [Object left]) {
    if (left == null) {
      if (right is num) return;
      throw RuntimeError(token, 'Operand must be a number.');
    }

    if (left is num && right is num) return;
    throw RuntimeError(token, 'Operands must be numbers.');
  }

  Object _evaluate(Expression expression) {
    return expression.acceptExpression(this);
  }

  Object _execute(Statement stmt) {
    return stmt.acceptStatement(this);
  }

  bool _isTruthy(Object right) {
    if (right == null) return false;
    if (right is bool) {
      return right;
    }
    return false;
  }

  Object _lookupVariable(Token name, Expression expression) {
    var distance = _locals[expression];
    var result;
    if (distance != null) {
      result = _environment.fetch(name);
    } else {
      result = _globals.fetch(name);
    }
    return result;
  }
}

class Return {
  final Object value;

  Return(this.value);
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
