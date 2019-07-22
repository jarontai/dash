import 'package:dash/dash.dart';
import 'package:test/test.dart';

void main() {
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
      var tokens = Scanner(inputs[i]).scanTokens();
      expect(Parser(tokens).parseExpression(), expects[i]);
    }
  });

  test('var statements', () {
    var inputs = ['var one = 1;', 'var two = 2;', 'var string = "string";'];

    var expects = ['one', 'two', 'string'];

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var tokens = Scanner(input).scanTokens();
      var stmts = Parser(tokens).parse();
      expect(stmts[0], isA<VarStatement>());
      expect((stmts[0] as VarStatement).name.lexeme, expects[i]);
      expect((stmts[0] as VarStatement).initializer, isA<LiteralExpression>());
    }
  });

  test('assign statements', () {
    var inputs = ['var one = 1; one = 2;'];

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var tokens = Scanner(input).scanTokens();
      var stmts = Parser(tokens).parse();
      expect(stmts[0], isA<VarStatement>());
      expect(stmts[1], isA<ExpressionStatement>());
      expect((stmts[1] as ExpressionStatement).expression,
          isA<AssignExpression>());
    }
  });

  test('block statements', () {
    var inputs = ['{ var one = 1; one = 2; }'];

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var tokens = Scanner(input).scanTokens();
      var stmts = Parser(tokens).parse();
      expect(stmts[0], isA<BlockStatement>());
      expect((stmts[0] as BlockStatement).statements.length, 2);
    }
  });

  test('if statements', () {
    var inputs = ['var one = 1; if (one > 1) { one = 2; } else { one = 3; }'];

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var tokens = Scanner(input).scanTokens();
      var stmts = Parser(tokens).parse();
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
      var input = inputs[i];
      var tokens = Scanner(input).scanTokens();
      var stmts = Parser(tokens).parse();
      expect(stmts[0], isA<VarStatement>());
      expect(stmts[1], isA<ExpressionStatement>());
      expect(stmts[2], isA<ExpressionStatement>());
      expect((stmts[1] as ExpressionStatement).expression, isA<LogicalExpression>());
      expect((stmts[2] as ExpressionStatement).expression, isA<LogicalExpression>());
    }
  });

  // test('return statement', () {
  //   var input = '''
  //     return 1;
  //     return 2.5;
  //     return result;''';

  //   var expects = [
  //     '1',
  //     '2.5',
  //     'result',
  //   ];

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(program.statements.length, 3);
  //   expect(parser.errors.isEmpty, true);

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ReturnStatement>());

  //     var returnStmt = stmt as ReturnStatement;
  //     expect(returnStmt.tokenLiteral, 'return');
  //     expect(returnStmt.value.toString(), expects[i]);
  //   }
  // });

  // test('statement construction', () {
  //   var program = Program();
  //   program.addStatement(VarStatement(Tokens.kVar,
  //       name: Identifier(Token.identifier('myVar')),
  //       value: Identifier(Token.identifier('anotherVar'))));

  //   var result = '''var myVar = anotherVar;''';
  //   expect(program.toString(), result);
  // });

  // test('number literal expressions', () {
  //   var input = '''
  //     5.5;''';

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(program.statements.length, 1);
  //   expect(parser.errors.isEmpty, true);

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ExpressionStatement>());

  //     var expStmt = stmt as ExpressionStatement;
  //     expect(expStmt.expression, isA<NumberLiteral>());
  //     expect(expStmt.tokenLiteral, '5.5');
  //   }
  // });

  // test('string literal expressions', () {
  //   var input = '"123456"';

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(program.statements.length, 1);
  //   expect(parser.errors.isEmpty, true);

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ExpressionStatement>());

  //     var expStmt = stmt as ExpressionStatement;
  //     expect(expStmt.expression, isA<StringLiteral>());
  //     expect(expStmt.tokenLiteral, '123456');
  //   }
  // });

  // test('boolean literal expressions', () {
  //   var input = '''
  //     true;false;''';

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(program.statements.length, 2);
  //   expect(parser.errors.isEmpty, true);

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ExpressionStatement>());

  //     var expStmt = stmt as ExpressionStatement;
  //     expect(expStmt.expression, isA<BooleanLiteral>());
  //     expect(expStmt.tokenLiteral, isIn(['true', 'false']));
  //   }
  // });

  // test('prefix expressions', () {
  //   var input = '''
  //     -233;!88;''';

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(program.statements.length, 2);
  //   expect(parser.errors.isEmpty, true);

  //   var expectOps = ['-', '!'];
  //   var expectLiteral = ['233', '88'];

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ExpressionStatement>());
  //     var expStmt = stmt as ExpressionStatement;
  //     expect(expStmt.expression, isA<PrefixExpression>());

  //     var preExp = expStmt.expression as PrefixExpression;
  //     expect(preExp.op, expectOps[i]);

  //     expect(preExp.right, isA<NumberLiteral>());

  //     var literal = preExp.right as NumberLiteral;

  //     expect(literal.value.toString(), expectLiteral[i]);
  //     expect(literal.tokenLiteral, expectLiteral[i]);
  //   }
  // });

  // test('infix expressions', () {
  //   var input = '''
  //     5 + 5;
  //     5 - 5;
  //     5 * 5;
  //     5 / 5;
  //     5 > 5;
  //     5 < 5;
  //     5 >= 5;
  //     5 <= 5;
  //     5 == 5;
  //     5 != 5;
  //     true == false;
  //     true != false;
  //     ''';

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(program.statements.length, 12);
  //   expect(parser.errors.isEmpty, true);

  //   var expectOps = [
  //     '+',
  //     '-',
  //     '*',
  //     '/',
  //     '>',
  //     '<',
  //     '>=',
  //     '<=',
  //     '==',
  //     '!=',
  //     '==',
  //     '!='
  //   ];

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ExpressionStatement>());
  //     var expStmt = stmt as ExpressionStatement;
  //     expect(expStmt.expression, isA<InfixExpression>());

  //     var preExp = expStmt.expression as InfixExpression;

  //     expect(preExp.op, expectOps[i]);

  //     if (preExp.left is NumberLiteral) {
  //       expect(preExp.right, isA<NumberLiteral>());
  //       expect(preExp.left, isA<NumberLiteral>());

  //       var literalRight = preExp.right as NumberLiteral;
  //       var literalLeft = preExp.left as NumberLiteral;

  //       expect(literalLeft.value.toString(), '5');
  //       expect(literalRight.value.toString(), '5');
  //     } else if (preExp.left is BooleanLiteral) {
  //       expect(preExp.right, isA<BooleanLiteral>());
  //       expect(preExp.left, isA<BooleanLiteral>());

  //       var literalRight = preExp.right as BooleanLiteral;
  //       var literalLeft = preExp.left as BooleanLiteral;

  //       expect(literalLeft.value.toString(), 'true');
  //       expect(literalRight.value.toString(), 'false');
  //     }
  //   }
  // });

  // test('precedence tests', () {
  //   var input = '''
  //     -a * b;
  //     !-a;
  //     a + b + c;
  //     a + b - c;
  //     a * b * c;
  //     a * b / c;
  //     a + b / c;
  //     a + b * c + d / e - f;
  //     5 > 4 == 3 < 4;
  //     5 < 4 != 3 > 4;
  //     3 + 4 * 5 == 3 * 1+ 4 * 5;
  //     3 > 5 == false;
  //     3 < 5 == true;
  //     1 + (2 + 3) + 4;
  //     (5 + 5) * 2;
  //     2 / (5 + 5);
  //     -(5 + 5);
  //     !(true == true);
  //     add(a + b + c * d / f + g);
  //     add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8));
  //     ''';

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(parser.errors.isEmpty, true);

  //   var expects = [
  //     '((-a) * b)',
  //     '(!(-a))',
  //     '((a + b) + c)',
  //     '((a + b) - c)',
  //     '((a * b) * c)',
  //     '((a * b) / c)',
  //     '(a + (b / c))',
  //     '(((a + (b * c)) + (d / e)) - f)',
  //     '((5 > 4) == (3 < 4))',
  //     '((5 < 4) != (3 > 4))',
  //     '((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))',
  //     '((3 > 5) == false)',
  //     '((3 < 5) == true)',
  //     '((1 + (2 + 3)) + 4)',
  //     '((5 + 5) * 2)',
  //     '(2 / (5 + 5))',
  //     '(-(5 + 5))',
  //     '(!(true == true))',
  //     'add((((a + b) + ((c * d) / f)) + g))',
  //     'add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))'
  //   ];

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ExpressionStatement>());
  //     var expStmt = stmt as ExpressionStatement;
  //     expect(expStmt.expression, isA<Expression>());
  //     var preExp = expStmt.expression;
  //     expect(preExp.toString(), expects[i]);
  //   }
  // });

  // test('if statement', () {
  //   var input = '''
  //   if (x < y) { x; } else { y; }''';

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(program.statements.length, 1);
  //   expect(parser.errors.isEmpty, true);

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ExpressionStatement>());

  //     var varStmt = stmt as ExpressionStatement;
  //     expect(varStmt.expression, isA<IfExpression>());

  //     var exp = varStmt.expression as IfExpression;
  //     expect(exp.condition.toString(), '(x < y)');
  //     expect(exp.consequence.statements.length, 1);
  //     expect(exp.consequence.statements.first, isA<ExpressionStatement>());
  //     expect(exp.consequence.statements.first.toString(), 'x');
  //     expect(exp.alternative.statements.first, isA<ExpressionStatement>());
  //     expect(exp.alternative.statements.first.toString(), 'y');
  //   }
  // });

  // test('function literal', () {
  //   var input = '''
  //     (){};
  //     (x){};
  //     (x, y) {
  //       return x + y;
  //     };''';

  //   var expectParams = ['', 'x', 'x,y'];

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(program.statements.length, 3);
  //   expect(parser.errors.isEmpty, true);

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ExpressionStatement>());

  //     var exp = stmt as ExpressionStatement;
  //     expect(exp.expression, isA<FunctionLiteral>());

  //     var fn = exp.expression as FunctionLiteral;
  //     expect(fn.parameters.join(','), expectParams[i]);
  //   }
  // });

  // test('function call', () {
  //   var input = '''
  //     add(1, 2 * 3, 4 + 5);''';

  //   Lexer lexer = Lexer(input);
  //   Parser parser = Parser(lexer);
  //   Program program = parser.parseProgram();

  //   expect(program, isNotNull);
  //   expect(program.statements, isNotNull);
  //   expect(program.statements.length, 1);
  //   expect(parser.errors.isEmpty, true);

  //   for (var i = 0; i < program.statements.length; i++) {
  //     var stmt = program.statements[i];
  //     expect(stmt, isA<ExpressionStatement>());

  //     var expStmt = stmt as ExpressionStatement;
  //     expect(expStmt.expression, isA<CallExpression>());

  //     var exp = expStmt.expression as CallExpression;
  //     expect(exp.function.toString(), 'add');
  //     expect(exp.arguments.length, 3);
  //     expect(exp.arguments[0].toString(), '1');
  //     expect(exp.arguments[1].toString(), '(2 * 3)');
  //     expect(exp.arguments[2].toString(), '(4 + 5)');
  //   }
  // });
}
