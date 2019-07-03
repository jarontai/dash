import 'lexer.dart';
import 'ast.dart';

typedef PrefixParserFn = Expression Function();
typedef InfixParserFn = Expression Function(Expression expression);

class Parser {
  final Lexer _lexer;
  Token _currentToken;
  Token _peekToken;
  Token _deepPeekToken;
  final List<String> errors = [];
  final Map<TokenType, PrefixParserFn> _prefixParserFns = {};
  final Map<TokenType, InfixParserFn> _infixParserFns = {};
  final Map<TokenType, Precedence> _precedenceMap = {
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
    TokenType.lparen: Precedence.call
  };

  Parser(this._lexer) {
    _nextToken();
    _nextToken();
    _nextToken();

    _prefixParserFns[TokenType.identifier] = _parseIdentifer;
    _prefixParserFns[TokenType.number] = _parseNumberLiteral;
    _prefixParserFns[TokenType.minus] = _parsePrefixExpression;
    _prefixParserFns[TokenType.bang] = _parsePrefixExpression;
    _prefixParserFns[TokenType.ktrue] = _parseBoolean;
    _prefixParserFns[TokenType.kfalse] = _parseBoolean;
    _prefixParserFns[TokenType.lparen] = _parseLparen;
    _prefixParserFns[TokenType.kif] = _parseIfExpression;

    _infixParserFns[TokenType.eq] = _parseInfixExpression;
    _infixParserFns[TokenType.neq] = _parseInfixExpression;
    _infixParserFns[TokenType.lt] = _parseInfixExpression;
    _infixParserFns[TokenType.lte] = _parseInfixExpression;
    _infixParserFns[TokenType.gt] = _parseInfixExpression;
    _infixParserFns[TokenType.gte] = _parseInfixExpression;
    _infixParserFns[TokenType.plus] = _parseInfixExpression;
    _infixParserFns[TokenType.minus] = _parseInfixExpression;
    _infixParserFns[TokenType.mul] = _parseInfixExpression;
    _infixParserFns[TokenType.div] = _parseInfixExpression;
    _infixParserFns[TokenType.lparen] = _parseCallExpression;
  }

  _nextToken() {
    _currentToken = _peekToken;
    _peekToken = _deepPeekToken;
    _deepPeekToken = _lexer.nextToken();
  }

  Program parseProgram() {
    Program program = Program();
    while (_currentToken.tokenType != TokenType.eof) {
      if (_currentToken.tokenType == TokenType.illegal) {
        errors.add('Illegal token: ${_currentToken}');
        break;
      }

      var stmt = _parseStatement();
      if (stmt != null) {
        program.addStatement(stmt);
      }
      _nextToken();
    }
    return program;
  }

  Statement _parseStatement() {
    switch (_currentToken.tokenType) {
      case TokenType.kvar:
        return _parseVarStatement();
        break;
      case TokenType.kreturn:
        return _parseReturnStatement();
        break;
      default:
        return _parseExpressionStatement();
    }
  }

  Statement _parseVarStatement() {
    var stmt = VarStatement(_currentToken);

    if (!_expectPeek(TokenType.identifier)) {
      return null;
    }

    stmt.name = Identifier(_currentToken);

    if (!_expectPeek(TokenType.assign)) {
      return null;
    }

    _nextToken();
    stmt.value = _parseExpression(Precedence.lowest);

    while (!_currentTokenIs(TokenType.semi)) {
      _nextToken();
    }
    return stmt;
  }

  Statement _parseReturnStatement() {
    var stmt = ReturnStatement(_currentToken);

    _nextToken();

    stmt.value = _parseExpression(Precedence.lowest);

    while (!_currentTokenIs(TokenType.semi)) {
      _nextToken();
    }
    return stmt;
  }

  ExpressionStatement _parseExpressionStatement() {
    var stmt = ExpressionStatement(_currentToken);
    stmt.expression = _parseExpression(Precedence.lowest);

    if (_peekTokenIs(TokenType.semi)) {
      _nextToken();
    }
    return stmt;
  }

  Expression _parseExpression(Precedence precedence) {
    var prefix = _prefixParserFns[_currentToken.tokenType];
    if (prefix == null) {
      errors.add('No prefix parse funtion found for: ${_currentToken}');
      return null;
    }

    var leftExp = prefix();
    while (!_peekTokenIs(TokenType.semi) &&
        precedence.index < _peekPrecedence().index) {
      var infix = _infixParserFns[_peekToken.tokenType];
      if (infix == null) {
        return leftExp;
      }
      _nextToken();
      leftExp = infix(leftExp);
    }

    return leftExp;
  }

  Expression _parseIdentifer() {
    return Identifier(_currentToken);
  }

  Expression _parseNumberLiteral() {
    num value = num.tryParse(_currentToken.literal);
    if (value == null) {
      errors.add('NumberLiteral parse error: ${_currentToken.literal}');
      return null;
    }
    return NumberLiteral(_currentToken, value);
  }

  Expression _parseBoolean() {
    return BooleanLiteral(_currentToken, _currentTokenIs(TokenType.ktrue));
  }

  Expression _parsePrefixExpression() {
    var exp = PrefixExpression(_currentToken, _currentToken.literal);
    _nextToken();
    exp.right = _parseExpression(Precedence.prefix);
    return exp;
  }

  Expression _parseInfixExpression(Expression left) {
    var exp = InfixExpression(_currentToken, _currentToken.literal, left);
    var precedence = _currPrecedence();
    _nextToken();
    exp.right = _parseExpression(precedence);
    return exp;
  }

  Expression _parseLparen() {
    if (_peekTokenIs(TokenType.rparen) ||
        _deepPeekTokenIs(TokenType.comma) ||
        _deepPeekTokenIs(TokenType.rparen)) {
      return _parseFunctionLiteral();
    }
    return _parseGroupedExpression();
  }

  Expression _parseGroupedExpression() {
    _nextToken();
    var exp = _parseExpression(Precedence.lowest);
    if (!_expectPeek(TokenType.rparen)) {
      return null;
    }
    return exp;
  }

  Expression _parseFunctionLiteral() {
    var fn = FunctionLiteral(_currentToken);
    if (!_peekTokenIs(TokenType.rparen) &&
        !_deepPeekTokenIs(TokenType.comma) &&
        !_deepPeekTokenIs(TokenType.rparen)) {
      return null;
    }

    fn.parameters.addAll(_parseFunctionParameters());
    if (!_expectPeek(TokenType.lbrace)) {
      return null;
    }
    fn.body = _parseBlockStatement();

    return fn;
  }

  List<Identifier> _parseFunctionParameters() {
    var result = <Identifier>[];

    if (_peekTokenIs(TokenType.rparen)) {
      _nextToken();
      return result;
    }

    _nextToken();

    result.add(Identifier(_currentToken));
    while (_peekTokenIs(TokenType.comma)) {
      _nextToken();
      _nextToken();
      result.add(Identifier(_currentToken));
    }

    if (!_expectPeek(TokenType.rparen)) {
      return null;
    }

    return result;
  }

  Expression _parseIfExpression() {
    var exp = IfExpression(_currentToken);
    if (!_expectPeek(TokenType.lparen)) {
      return null;
    }

    _nextToken();

    exp.condition = _parseExpression(Precedence.lowest);
    if (!_expectPeek(TokenType.rparen)) {
      return null;
    }
    if (!_expectPeek(TokenType.lbrace)) {
      return null;
    }

    exp.consequence = _parseBlockStatement();

    if (_peekTokenIs(TokenType.kelse)) {
      _nextToken();

      if (!_expectPeek(TokenType.lbrace)) {
        return null;
      }

      exp.alternative = _parseBlockStatement();
    }

    return exp;
  }

  Expression _parseCallExpression(Expression function) {
    var exp = CallExpression(_currentToken, function);
    exp.arguments = _parseCallArguments();
    return exp;
  }

  List<Expression> _parseCallArguments() {
    var result = <Expression>[];
    if (_peekTokenIs(TokenType.rparen)) {
      return result;
    }

    _nextToken();
    result.add(_parseExpression(Precedence.lowest));

    while (_peekTokenIs(TokenType.comma)) {
      _nextToken();
      _nextToken();
      result.add(_parseExpression(Precedence.lowest));
    }

    if (!_expectPeek(TokenType.rparen)) {
      return null;
    }

    return result;
  }

  BlockStatement _parseBlockStatement() {
    var block = BlockStatement(_currentToken);
    _nextToken();

    while (!_currentTokenIs(TokenType.rbrace)) {
      var stmt = _parseStatement();
      if (stmt != null) {
        block.statements.add(stmt);
      }
      _nextToken();
    }

    return block;
  }

  bool _expectPeek(TokenType tokenType) {
    if (_peekTokenIs(tokenType)) {
      _nextToken();
      return true;
    } else {
      _peekError(tokenType);
      return false;
    }
  }

  bool _peekTokenIs(TokenType tokenType) {
    var result = false;
    if (_peekToken != null && _peekToken.tokenType == tokenType) {
      result = true;
    }
    return result;
  }

  bool _deepPeekTokenIs(TokenType tokenType) {
    var result = false;
    if (_deepPeekToken != null && _deepPeekToken.tokenType == tokenType) {
      result = true;
    }
    return result;
  }

  bool _currentTokenIs(TokenType tokenType) {
    var result = false;
    if (_currentToken != null && _currentToken.tokenType == tokenType) {
      result = true;
    }
    return result;
  }

  Precedence _currPrecedence() =>
      _precedenceMap[_currentToken.tokenType] ?? Precedence.lowest;

  Precedence _peekPrecedence() =>
      _precedenceMap[_peekToken.tokenType] ?? Precedence.lowest;

  _peekError(TokenType tokenType) {
    var msg =
        'Expected next token to be $tokenType, got ${_peekToken.tokenType}';
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
