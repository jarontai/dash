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
  final Map<TokenType, Precedence> precedenceMap = {
    TokenType.eq: Precedence.equals,
    TokenType.neq: Precedence.equals,
    TokenType.lt: Precedence.ltgt,
    TokenType.lte: Precedence.ltgt,
    TokenType.gt: Precedence.ltgt,
    TokenType.gte: Precedence.ltgt,
    TokenType.plus: Precedence.sum,
    TokenType.minus: Precedence.sum,
    TokenType.mul: Precedence.product,
    TokenType.div: Precedence.product,
  };

  Parser(this.lexer) {
    nextToken();
    nextToken();

    prefixParserFns[TokenType.identifier] = parseIdentifer;
    prefixParserFns[TokenType.number] = parseNumberLiteral;
    prefixParserFns[TokenType.minus] = parsePrefixExpression;
    prefixParserFns[TokenType.bang] = parsePrefixExpression;
    prefixParserFns[TokenType.ktrue] = parseBoolean;
    prefixParserFns[TokenType.kfalse] = parseBoolean;
    prefixParserFns[TokenType.lparen] = parseGroupedExpression;
    prefixParserFns[TokenType.kif] = parseIfExpression;

    infixParserFns[TokenType.eq] = parseInfixExpression;
    infixParserFns[TokenType.neq] = parseInfixExpression;
    infixParserFns[TokenType.lt] = parseInfixExpression;
    infixParserFns[TokenType.lte] = parseInfixExpression;
    infixParserFns[TokenType.gt] = parseInfixExpression;
    infixParserFns[TokenType.gte] = parseInfixExpression;
    infixParserFns[TokenType.plus] = parseInfixExpression;
    infixParserFns[TokenType.minus] = parseInfixExpression;
    infixParserFns[TokenType.mul] = parseInfixExpression;
    infixParserFns[TokenType.div] = parseInfixExpression;
  }

  nextToken() {
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
      nextToken();
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
      nextToken();
    }
    return stmt;
  }

  Statement parseReturnStatement() {
    var stmt = ReturnStatement(currentToken);

    nextToken();

    // TODO:

    while (!currentTokenIs(TokenType.semi)) {
      nextToken();
    }
    return stmt;
  }

  ExpressionStatement parseExpressionStatement() {
    var stmt = ExpressionStatement(currentToken);
    stmt.expression = parseExpression(Precedence.lowest);

    if (peekTokenIs(TokenType.semi)) {
      nextToken();
    }
    return stmt;
  }

  Expression parseExpression(Precedence precedence) {
    var prefix = prefixParserFns[currentToken.tokenType];
    if (prefix == null) {
      errors.add('No prefix parse funtion found for: ${currentToken}');
      return null;
    }

    var leftExp = prefix();    
    while (!peekTokenIs(TokenType.semi) && precedence.index < peekPrecedence().index) {
      var infix = infixParserFns[peekToken.tokenType];
      if (infix == null) {
        return leftExp;
      }
      nextToken();
      leftExp = infix(leftExp);
    }
  
    return leftExp;
  }

  Expression parseIdentifer() {
    return Identifier(currentToken);
  }

  Expression parseNumberLiteral() {
    num value = num.tryParse(currentToken.literal);
    if (value == null) {
      errors.add('NumberLiteral parse error: ${currentToken.literal}');
      return null;
    }
    return NumberLiteral(currentToken, value);
  }

  Expression parseBoolean() {
    return BooleanLiteral(currentToken, currentTokenIs(TokenType.ktrue));
  }

  Expression parsePrefixExpression() {
    var exp = PrefixExpression(currentToken, currentToken.literal);
    nextToken();
    exp.right = parseExpression(Precedence.prefix);
    return exp;
  }

  Expression parseInfixExpression(Expression left) {
    var exp = InfixExpression(currentToken, currentToken.literal, left);
    var precedence = currPrecedence();
    nextToken();
    exp.right = parseExpression(precedence);
    return exp;
  }

  Expression parseGroupedExpression() {
    nextToken();
    var exp = parseExpression(Precedence.lowest);
    if (!expectPeek(TokenType.rparen)) {
      return null;
    }
    return exp;
  }

  Expression parseIfExpression() {
    var exp = IfExpression(currentToken);
    if (!expectPeek(TokenType.lparen)) {
      return null;
    }

    nextToken();
    
    exp.condition = parseExpression(Precedence.lowest);
    if (!expectPeek(TokenType.rparen)) {
      return null;
    }
    if (!expectPeek(TokenType.lbrace)) {
      return null;
    }
    
    exp.consequence = parseBlockStatement();

    if (peekTokenIs(TokenType.kelse)) {
      nextToken();

      if (!expectPeek(TokenType.lbrace)) {
        return null;
      }

      exp.alternative = parseBlockStatement();
    }

    return exp;
  }

  BlockStatement parseBlockStatement() {
    var block = BlockStatement(currentToken);
    nextToken();

    while (!currentTokenIs(TokenType.rbrace)) {
      var stmt = parseStatement();
      if (stmt != null) {
        block.statements.add(stmt);
      }
      nextToken();
    }

    return block;
  }

  bool expectPeek(TokenType tokenType) {
    if (peekTokenIs(tokenType)) {
      nextToken();
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

  Precedence currPrecedence() => precedenceMap[currentToken.tokenType] ?? Precedence.lowest;
  
  Precedence peekPrecedence() => precedenceMap[peekToken.tokenType] ?? Precedence.lowest;

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

