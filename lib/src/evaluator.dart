import 'ast.dart' as ast;
import 'object.dart';

class Evaluator {
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
      result = evalPrefixExpression(node.op, right);
    } else if (node is ast.InfixExpression) {
      var left = eval(node.left);
      var right = eval(node.right);
      result = evalInfixExpression(node.op, left, right);
    } else if (node is ast.BlockStatement) {
      result = evalBlockStatements(node.statements);
    } else if (node is ast.IfExpression) {
      result = evalIfExpression(node);
    } else if (node is ast.ReturnStatement) {
      result = ReturnValue(eval(node.value));
    }

    return result;
  }

  EvalObject evalBlockStatements(List<ast.Statement> statements) {
    EvalObject result;

    for (ast.Statement stmt in statements) {
      result = eval(stmt);
      if (result != null && result is ReturnValue) {
        break;
      }
    }

    return result;
  }

  EvalObject evalPrefixExpression(String op, EvalObject right) {
    EvalObject result = Null();

    switch (op) {
      case '!':
        result = evalBangOperatorExpression(right);
        break;

      case '-':
        result = evalMinusPrefixOperatorExpression(right);
        break;
    }

    return result;
  }

  EvalObject evalBangOperatorExpression(EvalObject right) {
    EvalObject result = Null();

    if (right is Boolean) {
      result = right.value ? Boolean(false) : Boolean(true);
    }

    return result;
  }

  EvalObject evalMinusPrefixOperatorExpression(EvalObject right) {
    EvalObject result = Null();

    if (right is Number) {
      result = Number(-right.value);
    }

    return result;
  }

  EvalObject evalInfixExpression(String op, EvalObject left, EvalObject right) {
    EvalObject result = Null();

    if (left is Number && right is Number) {
      result = evalNumberInfixOperatorExpression(op, left, right);
    } else if (op == '==') {
      result = Boolean(left == right);
    } else if (op == '!=') {
      result = Boolean(left != right);
    }

    return result;
  }

  EvalObject evalNumberInfixOperatorExpression(
      String op, Number left, Number right) {
    EvalObject result = Null();

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
    }

    return result;
  }

  EvalObject evalIfExpression(ast.IfExpression node) {
    var condition = eval(node.condition);

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
      }
      result = evalResult;
    }

    return result;
  }
}
