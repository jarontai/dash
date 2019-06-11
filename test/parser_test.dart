import 'package:dash/dash.dart';
import 'package:dash/src/ast.dart';
import 'package:test/test.dart';

void main() {
  test('var statement', () {
    var input = '''
      var one = 1;
      var two = 2;
      var three = 3;''';

    var expectIdentifiers = ['one', 'two', 'three'];

    Lexer lexer = Lexer(input);
    Parser parser = Parser(lexer);
    Program program = parser.parseProgram();

    expect(program, isNotNull);
    expect(program.statements, isNotNull);
    expect(program.statements.length, 3);
    expect(parser.errors.isEmpty, true);

    for (var i = 0; i < program.statements.length; i++) {
      var stmt = program.statements[i];
      expect(stmt, isA<VarStatement>());

      var identifier = expectIdentifiers[i];
      var varStmt = stmt as VarStatement;
      expect(varStmt.name.value, identifier);
      expect(varStmt.name.tokenLiteral, identifier);
    }
  });

  test('return statement', () {
    var input = '''
      return 1;
      return 2.5;
      return result;''';

    Lexer lexer = Lexer(input);
    Parser parser = Parser(lexer);
    Program program = parser.parseProgram();

    expect(program, isNotNull);
    expect(program.statements, isNotNull);
    expect(program.statements.length, 3);
    expect(parser.errors.isEmpty, true);

    for (var i = 0; i < program.statements.length; i++) {
      var stmt = program.statements[i];
      expect(stmt, isA<ReturnStatement>());

      var varStmt = stmt as ReturnStatement;
      expect(varStmt.tokenLiteral, 'return');
    }
  });

  test('statement construction', () {
    var program = Program();
    program.addStatement(VarStatement(Tokens.kVar,
        name: Identifier(Token.identifier('myVar')),
        value: Identifier(Token.identifier('anotherVar'))));

    var result = '''var myVar = anotherVar;''';
    expect(program.toString(), result);
  });

  test('identifier expressions', () {
    var input = '''
      myVar;''';

    Lexer lexer = Lexer(input);
    Parser parser = Parser(lexer);
    Program program = parser.parseProgram();

    expect(program, isNotNull);
    expect(program.statements, isNotNull);
    expect(program.statements.length, 1);
    expect(parser.errors.isEmpty, true);

    for (var i = 0; i < program.statements.length; i++) {
      var stmt = program.statements[i];
      expect(stmt, isA<ExpressionStatement>());

      var expStmt = stmt as ExpressionStatement;
      expect(expStmt.expression, isA<Identifier>());
      expect(expStmt.tokenLiteral, 'myVar');
    }
  });

  test('number literal expressions', () {
    var input = '''
      5.5;''';

    Lexer lexer = Lexer(input);
    Parser parser = Parser(lexer);
    Program program = parser.parseProgram();

    expect(program, isNotNull);
    expect(program.statements, isNotNull);
    expect(program.statements.length, 1);
    expect(parser.errors.isEmpty, true);

    for (var i = 0; i < program.statements.length; i++) {
      var stmt = program.statements[i];
      expect(stmt, isA<ExpressionStatement>());

      var expStmt = stmt as ExpressionStatement;
      expect(expStmt.expression, isA<NumberLiteral>());
      expect(expStmt.tokenLiteral, '5.5');
    }
  });

  test('prefix expressions', () {
    var input = '''
      -233;!88;''';

    Lexer lexer = Lexer(input);
    Parser parser = Parser(lexer);
    Program program = parser.parseProgram();

    expect(program, isNotNull);
    expect(program.statements, isNotNull);
    expect(program.statements.length, 2);
    expect(parser.errors.isEmpty, true);

    var expectOps = ['-', '!'];
    var expectLiteral = ['233', '88'];

    for (var i = 0; i < program.statements.length; i++) {
      var stmt = program.statements[i];
      expect(stmt, isA<ExpressionStatement>());
      var expStmt = stmt as ExpressionStatement;
      expect(expStmt.expression, isA<PrefixExpression>());

      var preExp = expStmt.expression as PrefixExpression;
      expect(preExp.op, expectOps[i]);

      expect(preExp.right, isA<NumberLiteral>());

      var literal = preExp.right as NumberLiteral;

      expect(literal.value.toString(), expectLiteral[i]);
      expect(literal.tokenLiteral, expectLiteral[i]);
    }
  });

  test('infix expressions', () {
    var input = '''
      5 + 5;
      5 - 5;
      5 * 5;
      5 / 5;
      5 > 5;
      5 < 5;
      5 >= 5;
      5 <= 5;
      5 == 5;
      5 != 5;''';

    Lexer lexer = Lexer(input);
    Parser parser = Parser(lexer);
    Program program = parser.parseProgram();

    expect(program, isNotNull);
    expect(program.statements, isNotNull);
    expect(program.statements.length, 10);
    expect(parser.errors.isEmpty, true);

    var expectOps = ['+', '-', '*', '/', '>', '<', '>=', '<=', '==', '!='];

    for (var i = 0; i < program.statements.length; i++) {
      var stmt = program.statements[i];
      expect(stmt, isA<ExpressionStatement>());
      var expStmt = stmt as ExpressionStatement;
      expect(expStmt.expression, isA<InfixExpression>());

      var preExp = expStmt.expression as InfixExpression;

      print(preExp);

      expect(preExp.op, expectOps[i]);

      expect(preExp.right, isA<NumberLiteral>());
      expect(preExp.left, isA<NumberLiteral>());

      var literalRight = preExp.right as NumberLiteral;
      var literalLeft = preExp.left as NumberLiteral;

      expect(literalRight.value.toString(), '5');
      expect(literalLeft.value.toString(), '5');
    }
  });

  test('precedence tests', () {
    var input = '''
      -a * b;
      !-a;
      a + b + c;
      a + b - c;
      a * b * c;
      a * b / c;
      a + b / c;
      a + b * c + d / e - f;
      5 > 4 == 3 < 4;
      5 < 4 != 3 > 4;
      3 + 4 * 5 == 3 * 1+ 4 * 5;
      ''';

    Lexer lexer = Lexer(input);
    Parser parser = Parser(lexer);
    Program program = parser.parseProgram();

    expect(program, isNotNull);
    expect(program.statements, isNotNull);
    expect(parser.errors.isEmpty, true);

    var expects = [
      '((-a) * b)',
      '(!(-a))',
      '((a + b) + c)',
      '((a + b) - c)',
      '((a * b) * c)',
      '((a * b) / c)',
      '(a + (b / c))',
      '(((a + (b * c)) + (d / e)) - f)',
      '((5 > 4) == (3 < 4))',
      '((5 < 4) != (3 > 4))',
      '((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))'
    ];

    for (var i = 0; i < program.statements.length; i++) {
      var stmt = program.statements[i];
      expect(stmt, isA<ExpressionStatement>());
      var expStmt = stmt as ExpressionStatement;
      expect(expStmt.expression, isA<Expression>());
      var preExp = expStmt.expression;
      expect(preExp.toString(), expects[i]);
    }
  });
}
