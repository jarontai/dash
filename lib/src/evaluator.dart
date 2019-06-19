import 'ast.dart' as ast;
import 'object.dart';

class Evaluator {
  EvalObject eval(ast.Node node) {
    EvalObject result;

    if (node is ast.Program) {
      result = evalStatements(node.statements);
    } else if (node is ast.ExpressionStatement) {
      result = eval(node.expression);
    } else if (node is ast.NumberLiteral) {
      result = Number(node.value);
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
}
