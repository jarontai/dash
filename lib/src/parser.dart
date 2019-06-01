import 'lexer.dart';
import 'ast.dart';

class Parser {
  Lexer lexer;
  Token currentToken;
  Token peekToken;

  Parser(this.lexer) {
    _nextToken();
    _nextToken();
  }

  _nextToken() {
    currentToken = peekToken;
    peekToken = lexer.nextToken();
  }

  Program parseProgram() {
    Program program = Program();
    while (currentToken.tokenType != TokenType.EOF) {
      var stmt = parseStatement();
      if (stmt != null) {
        program.addStatement(stmt);
      }
      _nextToken();
    }
    return program;
  }

  Statement parseStatement() {
    // TODO:
  }
}
