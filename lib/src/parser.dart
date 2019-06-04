import 'lexer.dart';
import 'ast.dart';

typedef PrefixParserFn = Expression Function();
typedef InfixParserFn = Expression Function(Expression expression);

class Parser {
  final Lexer lexer;
  Token currentToken;
  Token peekToken;
  final List<String> errors = [];
  final Map<TokenType, PrefixParserFn> prefixParserFns = {};
  final Map<TokenType, InfixParserFn> infixParserFns = {};

  Parser(this.lexer) {
    _nextToken();
    _nextToken();

    prefixParserFns[TokenType.identifier] = parseIdentifer;
  }

  _nextToken() {
    currentToken = peekToken;
    peekToken = lexer.nextToken();
  }

  Program parseProgram() {
    Program program = Program();
    while (currentToken.tokenType != TokenType.eof) {
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
      case TokenType.kvar:
        return parseVarStatement();
        break;
      case TokenType.kreturn:
        return parseReturnStatement();
        break;
      default:
        return parseExpressionStatement();
    }
  }

  Statement parseVarStatement() {
    var stmt = VarStatement(currentToken);

    if (!expectPeek(TokenType.identifier)) {
      return null;
    }

    stmt.name = Identifier(currentToken);

    if (!expectPeek(TokenType.assign)) {
      return null;
    }

    // TODO:

    while (!currentTokenIs(TokenType.semi)) {
      _nextToken();
    }
    return stmt;
  }

  Statement parseReturnStatement() {
    var stmt = ReturnStatement(currentToken);

    _nextToken();

    // TODO:

    while (!currentTokenIs(TokenType.semi)) {
      _nextToken();
    }
    return stmt;
  }

  ExpressionStatement parseExpressionStatement() {
    var stmt = ExpressionStatement(currentToken);
    stmt.expression = parseExpression(Precedence.lowest);

    while (!currentTokenIs(TokenType.semi)) {
      _nextToken();
    }
    return stmt;
  }

  Expression parseExpression(Precedence precedence) {
    var prefix = prefixParserFns[currentToken.tokenType];
    if (prefix == null) {
      return null;
    }

    var leftExp = prefix();
    
    return leftExp;
  }

  Expression parseIdentifer() {
    return Identifier(currentToken);
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
    var msg =
        'Expected next token to be $tokenType, got ${peekToken.tokenType}';
    errors.add(msg);
  }
}

enum Precedence {
  lowest,
  equals, // ==
  ltgt, // > < >= <=
  sum, // + -
  product, // * /
  prefix, // -x or !x
  call // function()
}