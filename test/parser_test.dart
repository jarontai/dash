import 'package:dash/dash.dart';
import 'package:test/test.dart';

void main() {
  List<Statement> parse(String input) {
    var tokens = Scanner(input).scanTokens();
    return Parser(tokens).parse();
  }

  test('basic expressions', () {
    var inputs = [
      '1',
      '2',
      '"string"',
      'false',
      'true',
      '1 + 2',
      '1 + 2 / 1 + 3',
      '1 + 2 / (1 + 3)',
      '1 > 2',
      '1 <= 2',
    ];

    var expects = [
      '1',
      '2',
      'string',
      'false',
      'true',
      '(+ 1 2)',
      '(+ (+ 1 (/ 2 1)) 3)',
      '(+ 1 (/ 2 (group (+ 1 3))))',
      '(> 1 2)',
      '(<= 1 2)',
    ];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i] + ';');
      expect(stmts[0], isA<ExpressionStatement>());

      var expr = (stmts[0] as ExpressionStatement).expression;
      expect(Parser.astPrinter.print(expr), expects[i]);
    }
  });

  test('var statements', () {
    var inputs = ['var one = 1;', 'var two = 2;', 'var string = "string";'];

    var expects = ['one', 'two', 'string'];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i]);
      expect(stmts[0], isA<VarStatement>());
      expect((stmts[0] as VarStatement).name.lexeme, expects[i]);
      expect((stmts[0] as VarStatement).initializer, isA<LiteralExpression>());
    }
  });

  test('assign statements', () {
    var inputs = ['var one = 1; one = 2;'];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i]);
      expect(stmts[0], isA<VarStatement>());
      expect(stmts[1], isA<ExpressionStatement>());
      expect((stmts[1] as ExpressionStatement).expression,
          isA<AssignExpression>());
    }
  });

  test('block statements', () {
    var inputs = ['{ var one = 1; one = 2; }'];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i]);
      expect(stmts[0], isA<BlockStatement>());
      expect((stmts[0] as BlockStatement).statements.length, 2);
    }
  });

  test('if statements', () {
    var inputs = ['var one = 1; if (one > 1) { one = 2; } else { one = 3; }'];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i]);
      expect(stmts[0], isA<VarStatement>());
      expect(stmts[1], isA<IfStatement>());
      expect((stmts[1] as IfStatement).condition, isNotNull);
      expect((stmts[1] as IfStatement).thenBranch, isNotNull);
      expect((stmts[1] as IfStatement).elseBranch, isNotNull);
    }
  });

  test('logical', () {
    var inputs = ['var one = 1; (one > 1) && true; (one < 1) && false;'];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i]);
      expect(stmts[0], isA<VarStatement>());
      expect(stmts[1], isA<ExpressionStatement>());
      expect(stmts[2], isA<ExpressionStatement>());
      expect((stmts[1] as ExpressionStatement).expression,
          isA<LogicalExpression>());
      expect((stmts[2] as ExpressionStatement).expression,
          isA<LogicalExpression>());
    }
  });

  test('while loop', () {
    var inputs = ['var one = 1; while (one < 10) { one = one + 1; } '];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i]);
      expect(stmts[0], isA<VarStatement>());
      expect(stmts[1], isA<WhileStatement>());
      expect((stmts[1] as WhileStatement).condition, isNotNull);
      expect((stmts[1] as WhileStatement).body, isNotNull);
    }
  });

  test('for loop', () {
    var inputs = [
      '''
        var a = 0;
        var b = 1;

        while (a < 100) {
          var temp = a;
          a = b;
          b = temp + b;
        }
      '''
    ];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i]);
      expect(stmts[0], isA<VarStatement>());
      expect(stmts[1], isA<VarStatement>());
      expect(stmts[2], isA<WhileStatement>());
      var stmt = (stmts[2] as WhileStatement);
      expect(stmt.condition, isNotNull);
      expect(stmt.body, isNotNull);
      expect(stmt.body, isA<BlockStatement>());
      var block = stmt.body as BlockStatement;
      expect(block.statements[0], isA<VarStatement>());
      expect(block.statements[1], isA<ExpressionStatement>());
      expect(block.statements[2], isA<ExpressionStatement>());
    }
  });

  test('print funcion', () {
    var inputs = [
      '''
        var a = 1;
        print(a);
      '''
    ];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i]);
      expect(stmts[0], isA<VarStatement>());
      expect(stmts[1], isA<ExpressionStatement>());
      var stmt = (stmts[1] as ExpressionStatement);
      expect(stmt.expression, isA<CallExpression>());
    }
  });

  test('function', () {
    var inputs = [
      '''
        sayHi(first, last) {
          print("Hi, " + first + " " + last + "!");
          return 1;
        }
      '''
    ];

    for (var i = 0; i < inputs.length; i++) {
      var stmts = parse(inputs[i]);
      expect(stmts[0], isA<FunctionStatement>());
      var stmt = (stmts[0] as FunctionStatement);
      expect(stmt.name.lexeme, 'sayHi');
      expect(stmt.params.length, 2);
      expect(stmt.body, isNotNull);
      expect(stmt.body[0], isA<ExpressionStatement>());
      expect(stmt.body[1], isA<ReturnStatement>());
    }
  });
}
