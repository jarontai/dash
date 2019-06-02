import 'lexer.dart';
import 'ast.dart';

class Parser {
  Lexer lexer;
  Token currentToken;
  Token peekToken;
  List<String> errors;

  Parser(this.lexer) {
    _nextToken();
    _nextToken();
    errors = <String>[];
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
    switch (currentToken.tokenType) {
      case TokenType.VAR:
        return parseVarStatement();
        break;
      default:
    }
  }

  Statement parseVarStatement() {
    var stmt = VarStatement(currentToken);

    if (!expectPeek(TokenType.IDENTIFIER)) {
      return null;
    }

    stmt.name = Identifier(currentToken);

    if (!expectPeek(TokenType.ASSIGN)) {
      return null;
    }

    while (!currentTokenIs(TokenType.SEMI)) {
      _nextToken();
    }

    return stmt;
  }

  bool expectPeek(TokenType tokenType) {
    if (peekTokenIs(tokenType)) {
      _nextToken();
      return true;
    } else {
      peekError(tokenType);
      return false;
    }
  }

  bool peekTokenIs(TokenType tokenType) {
    var result = false;
    if (peekToken != null && peekToken.tokenType == tokenType) {
      result = true;
    }
    return result;
  }

  bool currentTokenIs(TokenType tokenType) {
    var result = false;
    if (currentToken != null && currentToken.tokenType == tokenType) {
      result = true;
    }
    return result;
  }

  peekError(TokenType tokenType) {
    var msg = 'Expected next token to be $tokenType, got ${peekToken.tokenType}';
    errors.add(msg);
  }
}
