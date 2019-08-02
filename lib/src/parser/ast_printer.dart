import '../scanner/token.dart';
import 'ast.dart';

// The pretty ast printer.

class AstPrinter implements ExpressionVisitor<String> {
  String print(Expression expr) {
    return expr.acceptExpression(this);
  }

  @override
  String visitAssignExpression(AssignExpression expression) {
    // TODO: implement visitAssignExpression
    return null;
  }

  @override
  String visitBinaryExpression(BinaryExpression expression) {
    return _parenthesize(
        expression.op.lexeme, [expression.left, expression.right]);
  }

  @override
  String visitCallExpression(CallExpression expression) {
    // TODO: implement visitCallExpression
    return null;
  }

  @override
  String visitGetExpression(GetExpression expression) {
    // TODO: implement visitGetExpression
    return null;
  }

  @override
  String visitGroupingExpression(GroupingExpression expression) {
    return _parenthesize('group', [expression.expression]);
  }

  @override
  String visitLiteralExpression(LiteralExpression expression) {
    if (expression.value == null) {
      return 'null';
    }
    return expression.value.toString();
  }

  @override
  String visitLogicalExpression(LogicalExpression expression) {
    // TODO: implement visitLogicalExpression
    return null;
  }

  @override
  String visitSetExpression(SetExpression expression) {
    // TODO: implement visitSetExpression
    return null;
  }

  @override
  String visitThisExpression(ThisExpression expression) {
    // TODO: implement visitThisExpression
    return null;
  }

  @override
  String visitUnaryExpression(UnaryExpression expression) {
    return _parenthesize(expression.op.lexeme, [expression.right]);
  }

  @override
  String visitVariableExpression(VariableExpression expression) {
    // TODO: implement visitVariableExpression
    return null;
  }

  String _parenthesize(String name, List<Expression> expressions) {
    var sb = StringBuffer();

    sb.write('($name');
    for (var expr in expressions) {
      sb.write(' ${expr.acceptExpression(this)}');
    }
    sb.write(')');

    return sb.toString();
  }
}

main(List<String> args) {
  var expression = BinaryExpression(
      UnaryExpression(
          Token(TokenType.MINUS, "-", null, 1), LiteralExpression(123)),
      Token(TokenType.STAR, "*", null, 1),
      GroupingExpression(LiteralExpression(45.67)));

  print(AstPrinter().print(expression));
}