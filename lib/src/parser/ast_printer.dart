import 'ast.dart';
import '../scanner/token.dart';

// The pretty ast printer.
class AstPrinter implements ExpressionVisitor<String> {
  @override
  String visitBinaryExpression(BinaryExpression expression) {
    return _parenthesize(
        expression.op.lexeme, [expression.left, expression.right]);
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
  String visitUnaryExpression(UnaryExpression expression) {
    return _parenthesize(expression.op.lexeme, [expression.right]);
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

  String print(Expression expr) {
    return expr.acceptExpression(this);
  }

  @override
  String visitVariableExpression(VariableExpression expression) {
    // TODO: implement visitVariableExpression
    return null;
  }

  @override
  String visitAssignExpression(AssignExpression expression) {
    // TODO: implement visitAssignExpression
    return null;
  }

  @override
  String visitLogicalExpression(LogicalExpression expression) {
    // TODO: implement visitLogicalExpression
    return null;
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
