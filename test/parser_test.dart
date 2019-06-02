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
    
    for (var i = 0; i < program.statements.length; i++) {
      var stmt = program.statements[i];
      expect(stmt, isA<VarStatement>());
      
      var identifier = expectIdentifiers[i];
      var varStmt = stmt as VarStatement;
      expect(varStmt.name.value, identifier);
      expect(varStmt.name.tokenLiteral, identifier);
    }

    expect(parser.errors.isEmpty, true);
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
    
    for (var i = 0; i < program.statements.length; i++) {
      var stmt = program.statements[i];
      expect(stmt, isA<ReturnStatement>());
      
      var varStmt = stmt as ReturnStatement;
      expect(varStmt.tokenLiteral, 'return');

    }

    expect(parser.errors.isEmpty, true);
  });  
}
