import 'ast.dart' as ast;
import 'object.dart';

export 'object.dart';

class Evaluator {
  Environment _env;

  Evaluator() {
    _env = Environment();
  }

  Evaluator.fromEnv(Environment env) {
    _env = env;
  }

  EvalObject eval(ast.Node node) {
    EvalObject result = Null();

    if (node is ast.Program) {
      result = evalProgram(node);
    } else if (node is ast.ExpressionStatement) {
      result = eval(node.expression);
    } else if (node is ast.NumberLiteral) {
      result = Number(node.value);
    } else if (node is ast.BooleanLiteral) {
      result = Boolean(node.value);
    } else if (node is ast.PrefixExpression) {
      var right = eval(node.right);
      if (right is ErrorObject) {
        result = right;
      } else {
        result = evalPrefixExpression(node.op, right);
      }
    } else if (node is ast.InfixExpression) {
      var left = eval(node.left);
      var right = eval(node.right);
      if (left is ErrorObject) {
        result = left;
      } else if (right is ErrorObject) {
        result = right;
      } else {
        result = evalInfixExpression(node.op, left, right);
      }
    } else if (node is ast.BlockStatement) {
      result = evalBlockStatements(node.statements);
    } else if (node is ast.IfExpression) {
      result = evalIfExpression(node);
    } else if (node is ast.ReturnStatement) {
      var val = eval(node.value);
      if (val is ErrorObject) {
        result = val;
      } else {
        result = ReturnValue(val);
      }
    } else if (node is ast.VarStatement) {
      var val = eval(node.value);
      if (val is! ErrorObject) {
        _env[node.name.value] = val;
      }
    } else if (node is ast.Identifier) {
      result = evalIdentifier(node);
    }

    return result;
  }

  EvalObject evalBlockStatements(List<ast.Statement> statements) {
    EvalObject result;

    for (ast.Statement stmt in statements) {
      result = eval(stmt);
      if (result != null && (result is ReturnValue || result is ErrorObject)) {
        break;
      }
    }

    return result;
  }

  EvalObject evalPrefixExpression(String op, EvalObject right) {
    EvalObject result;

    switch (op) {
      case '!':
        result = evalBangOperatorExpression(right);
        break;

      case '-':
        result = evalMinusPrefixOperatorExpression(right);
        break;

      default:
        result = ErrorObject.prefix(op, right);
    }

    return result;
  }

  EvalObject evalBangOperatorExpression(EvalObject right) {
    EvalObject result;

    if (right is Boolean) {
      result = right.value ? Boolean(false) : Boolean(true);
    } else {
      result = ErrorObject.prefix('!', right);
    }

    return result;
  }

  EvalObject evalMinusPrefixOperatorExpression(EvalObject right) {
    EvalObject result;

    if (right is Number) {
      result = Number(-right.value);
    } else {
      result = ErrorObject.prefix('-', right);
    }

    return result;
  }

  EvalObject evalInfixExpression(String op, EvalObject left, EvalObject right) {
    EvalObject result;

    if (left.runtimeType != right.runtimeType) {
      result = ErrorObject.infix(op, left, right, typeMismatch: true);
    } else if (left is Number && right is Number) {
      result = evalNumberInfixOperatorExpression(op, left, right);
    } else if (op == '==') {
      result = Boolean(left == right);
    } else if (op == '!=') {
      result = Boolean(left != right);
    } else {
      result = ErrorObject.infix(op, left, right);
    }

    return result;
  }

  EvalObject evalNumberInfixOperatorExpression(
      String op, Number left, Number right) {
    EvalObject result;

    num leftVal = left.value;
    num rightVal = right.value;

    switch (op) {
      case '+':
        result = Number(leftVal + rightVal);
        break;
      case '-':
        result = Number(leftVal - rightVal);
        break;
      case '*':
        result = Number(leftVal * rightVal);
        break;
      case '/':
        result = Number(leftVal / rightVal);
        break;
      case '<':
        result = Boolean(leftVal < rightVal);
        break;
      case '<=':
        result = Boolean(leftVal <= rightVal);
        break;
      case '>':
        result = Boolean(leftVal > rightVal);
        break;
      case '>=':
        result = Boolean(leftVal >= rightVal);
        break;
      case '==':
        result = Boolean(leftVal == rightVal);
        break;
      case '!=':
        result = Boolean(leftVal != rightVal);
        break;
      default:
        result = ErrorObject.prefix(op, right);
    }

    return result;
  }

  EvalObject evalIfExpression(ast.IfExpression node) {
    var condition = eval(node.condition);
    if (condition is ErrorObject) {
      return condition;
    }

    bool conditionVal = false;
    if (condition is Boolean) {
      if (condition.value) {
        conditionVal = true;
      }
    }

    if (conditionVal) {
      return eval(node.consequence);
    } else {
      return eval(node.alternative);
    }
  }

  EvalObject evalProgram(ast.Program program) {
    EvalObject result;

    for (ast.Statement stmt in program.statements) {
      var evalResult = eval(stmt);
      if (evalResult is ReturnValue) {
        result = evalResult.value;
        break;
      } else if (evalResult is ErrorObject) {
        result = evalResult;
        break;
      }
      result = evalResult;
    }

    return result;
  }

  EvalObject evalIdentifier(ast.Identifier node) {
    return _env.containsKey(node.value) ? _env[node.value] : ErrorObject.identifier(node.value);
  }
}
