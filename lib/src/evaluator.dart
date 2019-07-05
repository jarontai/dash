import 'ast.dart' as ast;
import 'object.dart';

export 'object.dart';

class Evaluator {
  EvalObject evalWithEnv(ast.Node node) {
    return eval(node, Environment());
  }

  EvalObject eval(ast.Node node, Environment env) {
    if (env == null) {
      env = Environment();
    }

    EvalObject result = Null();

    if (node is ast.Program) {
      result = evalProgram(node, env);
    } else if (node is ast.ExpressionStatement) {
      result = eval(node.expression, env);
    } else if (node is ast.NumberLiteral) {
      result = Number(node.value);
    } else if (node is ast.StringLiteral) {
      result = StringObject(node.value);
    } else if (node is ast.BooleanLiteral) {
      result = Boolean(node.value);
    } else if (node is ast.PrefixExpression) {
      var right = eval(node.right, env);
      if (right is ErrorObject) {
        result = right;
      } else {
        result = evalPrefixExpression(node.op, right);
      }
    } else if (node is ast.InfixExpression) {
      var left = eval(node.left, env);
      var right = eval(node.right, env);
      if (left is ErrorObject) {
        result = left;
      } else if (right is ErrorObject) {
        result = right;
      } else {
        result = evalInfixExpression(node.op, left, right);
      }
    } else if (node is ast.BlockStatement) {
      result = evalBlockStatements(node.statements, env);
    } else if (node is ast.IfExpression) {
      result = evalIfExpression(node, env);
    } else if (node is ast.ReturnStatement) {
      var val = eval(node.value, env);
      if (val is ErrorObject) {
        result = val;
      } else {
        result = ReturnValue(val);
      }
    } else if (node is ast.VarStatement) {
      var val = eval(node.value, env);
      if (val is! ErrorObject) {
        env.put(node.name.value, val);
      }
    } else if (node is ast.Identifier) {
      result = evalIdentifier(node, env);
    } else if (node is ast.FunctionLiteral) {
      result = FunctionObject(node.parameters, node.body, env);
    } else if (node is ast.CallExpression) {
      var fn = eval(node.function, env);
      if (fn is ErrorObject) {
        result = fn;
      } else {
        var args = evalExpressions(node.arguments, env);
        if (args.length == 1 && args[0] is ErrorObject) {
          result = args[0];
        } else {
          result = applyFunction(fn, args);
        }
      }
    }

    return result;
  }

  EvalObject evalProgram(ast.Program program, Environment env) {
    EvalObject result;

    for (ast.Statement stmt in program.statements) {
      var evalResult = eval(stmt, env);
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

  EvalObject evalBlockStatements(
      List<ast.Statement> statements, Environment env) {
    EvalObject result;

    for (ast.Statement stmt in statements) {
      result = eval(stmt, env);
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

  EvalObject evalIfExpression(ast.IfExpression node, Environment env) {
    var condition = eval(node.condition, env);
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
      return eval(node.consequence, env);
    } else {
      return eval(node.alternative, env);
    }
  }

  EvalObject evalIdentifier(ast.Identifier node, Environment env) {
    return env.containsKey(node.value)
        ? env.fetch(node.value)
        : ErrorObject.identifier(node.value);
  }

  List<EvalObject> evalExpressions(
      List<ast.Expression> arguments, Environment env) {
    var result = <EvalObject>[];
    for (var exp in arguments) {
      var val = eval(exp, env);
      if (val is ErrorObject) {
        return [val];
      }
      result.add(val);
    }
    return result;
  }

  EvalObject applyFunction(EvalObject fn, List<EvalObject> args) {
    if (fn is FunctionObject) {
      var extEnv =  Environment.withOuter(fn.env);
      for (var index = 0; index < fn.parameters.length; index++) {
        var p = fn.parameters[index];
        extEnv.put(p.value, args[index]);
      }
      var result = eval(fn.body, extEnv);
      if (result is ReturnValue) {
        return result.value;
      }
      return result;
    }
    return ErrorObject.fn(fn.type);
  }
}
