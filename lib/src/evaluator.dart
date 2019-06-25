import 'ast.dart' as ast;
import 'object.dart';

class Evaluator {
  EvalObject eval(ast.Node node) {
    EvalObject result = Null();

    if (node is ast.Program) {
      result = evalStatements(node.statements);
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
    }

    return result;
  }

  EvalObject evalStatements(List<ast.Statement> statements) {
    EvalObject result;

    for (ast.Statement stmt in statements) {
      result = eval(stmt);
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
}
