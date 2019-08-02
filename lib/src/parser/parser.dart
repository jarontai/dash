import '../runner.dart';
import '../scanner/token.dart';
import 'ast.dart';
import 'ast_printer.dart';

export 'ast.dart';

/// The parser, which response for producing ast [Expression]s from [Token]s.
class Parser {
  static final AstPrinter astPrinter = AstPrinter();
  static final _argsNumLimit = 8;
  final List<Token> _tokens;
  int _current = 0;

  Parser(this._tokens);

  List<Statement> parse() {
    var stmts = <Statement>[];
    try {
      while (!_isAtEnd()) {
        var stmt = _declaration();
        if (stmt != null) {
          stmts.add(stmt);
        }
      }
    } on ParseError catch (e) {
      Runner.reportError(e.token, e.message);
    }
    return stmts;
  }

  Expression _addition() {
    var expr = _multiplication();
    while (_matchAny([
      TokenType.MINUS,
      TokenType.PLUS,
    ])) {
      var op = _previous();
      var right = _multiplication();
      expr = BinaryExpression(expr, op, right);
    }
    return expr;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  Expression _and() {
    var expr = _equality();

    while (_match(TokenType.AND)) {
      var op = _previous();
      var right = _equality();
      expr = LogicalExpression(expr, op, right);
    }

    return expr;
  }

  Expression _assignment() {
    var expr = _or();

    if (_match(TokenType.EQUAL)) {
      var token = _previous();
      var value = _assignment();
      if (expr is VariableExpression) {
        var name = expr.name;
        return AssignExpression(name, value);
      } else if (expr is GetExpression) {
        return SetExpression(expr.object, expr.name, value);
      }

      _error(token, 'Invalid assignment target.');
    }

    return expr;
  }

  List<Statement> _block() {
    var stmts = <Statement>[];

    while (!_check(TokenType.RIGHT_BRACE) && !_isAtEnd()) {
      stmts.add(_declaration());
    }

    _consume(TokenType.RIGHT_BRACE, 'Expect \'}\' after block.');
    return stmts;
  }

  Expression _call() {
    var expr = _primary();

    while (true) {
      if (_match(TokenType.LEFT_PAREN)) {
        expr = _finishCall(expr);
      } else if (_match(TokenType.DOT)) {
        var name =
            _consume(TokenType.IDENTIFIER, 'Expect property name after \'.\'.');
        expr = GetExpression(expr, name);
      } else {
        break;
      }
    }

    return expr;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  bool _checkSeq(List<TokenType> types) {
    if (_isAtEnd()) return false;
    var result = true;
    var index = 0;
    for (var type in types) {
      var peekToken = _peek(index);
      if (peekToken.type != type) {
        result = false;
        break;
      }
      index++;
    }
    return result;
  }

  bool _checkUntil(TokenType type,
      [int skipTokenNum = 1,
      List<TokenType> stopTokens = const [
        TokenType.EOF,
        TokenType.SEMICOLON
      ]]) {
    if (_isAtEnd()) return false;
    var result = false;
    for (var index = 0; index < skipTokenNum; index++) {
      var peekToken = _peek(index);
      if (stopTokens.contains(peekToken.type)) {
        break;
      }
      if (peekToken.type == type) {
        result = true;
        break;
      }
    }
    return result;
  }

  Statement _classDeclaration() {
    var name = _consume(TokenType.IDENTIFIER, "Expect class name.");
    _consume(TokenType.LEFT_BRACE, "Expect '{' before class body.");

    var methods = <FunctionStatement>[];
    while (!_check(TokenType.RIGHT_BRACE) && !_isAtEnd()) {
      methods.add(_functionStatement("method"));
    }

    _consume(TokenType.RIGHT_BRACE, "Expect '}' after class body.");

    return ClassStatement(name, methods);
  }

  Expression _comparison() {
    var expr = _addition();
    while (_matchAny([
      TokenType.GREATER,
      TokenType.GREATER_EQUAL,
      TokenType.LESS,
      TokenType.LESS_EQUAL
    ])) {
      var op = _previous();
      var right = _addition();
      expr = BinaryExpression(expr, op, right);
    }
    return expr;
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();

    throw _error(_peek(), message);
  }

  Statement _declaration() {
    try {
      if (_match(TokenType.VAR)) {
        return _varDeclaration();
      }

      if (_match(TokenType.CLASS)) {
        return _classDeclaration();
      }

      if (_checkSeq([TokenType.IDENTIFIER, TokenType.LEFT_PAREN])) {
        if (_checkUntil(TokenType.LEFT_BRACE, 20)) {
          return _functionStatement('function');
        }
      }

      return _statement();
    } on ParseError catch (e) {
      _synchronize();
      Runner.reportError(e.token, e.message);
      return null;
    }
  }

  Expression _equality() {
    var expr = _comparison();
    while (_matchAny([TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL])) {
      var op = _previous();
      var right = _comparison();
      expr = BinaryExpression(expr, op, right);
    }
    return expr;
  }

  ParseError _error(Token token, String message) {
    return ParseError(token, message);
  }

  Expression _expression() {
    return _assignment();
  }

  Statement _expressionStatement() {
    var expr = _expression();
    _consume(TokenType.SEMICOLON, 'Expect \';\' after expression.');
    return ExpressionStatement(expr);
  }

  Expression _finishCall(Expression callee) {
    var arguments = <Expression>[];
    if (!_check(TokenType.RIGHT_PAREN)) {
      do {
        if (arguments.length > _argsNumLimit) {
          _error(_peek(), 'Cannot have more than $_argsNumLimit arguments.');
        }

        arguments.add(_expression());
      } while (_match(TokenType.COMMA));
    }

    var paren =
        _consume(TokenType.RIGHT_PAREN, 'Expect \')\' after arguments.');
    return CallExpression(callee, paren, arguments);
  }

  Statement _forStatement() {
    _consume(TokenType.LEFT_PAREN, 'Expect \'(\' after \'for\'.');

    Statement initializer;
    if (_match(TokenType.SEMICOLON)) {
      initializer = null;
    } else if (_match(TokenType.VAR)) {
      initializer = _varDeclaration();
    } else {
      initializer = _expressionStatement();
    }

    Expression condition;
    if (!_check(TokenType.SEMICOLON)) {
      condition = _expression();
    }
    _consume(TokenType.SEMICOLON, 'Expect \';\' after loop condition.');

    Expression increment;
    if (!_check(TokenType.RIGHT_PAREN)) {
      increment = _expression();
    }
    _consume(TokenType.RIGHT_PAREN, 'Expect \')\' after for clauses.');

    var body = _statement();

    if (increment != null) {
      body = BlockStatement([body, ExpressionStatement(increment)]);
    }

    if (condition == null) {
      condition = LiteralExpression(true);
    }
    body = WhileStatement(condition, body);

    if (initializer != null) {
      body = BlockStatement([initializer, body]);
    }

    return body;
  }

  Statement _functionStatement(String kind, {Token varToken}) {
    var name = varToken != null
        ? varToken
        : _consume(TokenType.IDENTIFIER, 'Expect $kind name.');
    _consume(TokenType.LEFT_PAREN, 'Expect ( after $kind name.');
    var parameters = <Token>[];
    if (!_check(TokenType.RIGHT_PAREN)) {
      do {
        if (parameters.length > _argsNumLimit) {
          _error(_peek(), 'Cannot have more than $_argsNumLimit parameters.');
        }

        parameters
            .add(_consume(TokenType.IDENTIFIER, 'Expect parameter name.'));
      } while (_match(TokenType.COMMA));
    }
    _consume(TokenType.RIGHT_PAREN, 'Expect ) after parameters.');

    _consume(TokenType.LEFT_BRACE, 'Expect { before $kind body.');
    var body = _block();
    return FunctionStatement(name, parameters, body);
  }

  Statement _ifStatement() {
    _consume(TokenType.LEFT_PAREN, 'Expect \'(\' after if.');
    var condition = _expression();
    _consume(TokenType.RIGHT_PAREN, 'Expect \')\' after if condition.');

    var thenBranch = _statement();
    var elseBranch;
    if (_match(TokenType.ELSE)) {
      elseBranch = _statement();
    }

    return IfStatement(condition, thenBranch, elseBranch);
  }

  bool _isAtEnd() => _peek().type == TokenType.EOF;

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _matchAny(List<TokenType> types) {
    for (var type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  Expression _multiplication() {
    var expr = _unary();
    while (_matchAny([
      TokenType.SLASH,
      TokenType.STAR,
    ])) {
      var op = _previous();
      var right = _unary();
      expr = BinaryExpression(expr, op, right);
    }
    return expr;
  }

  Expression _or() {
    var expr = _and();

    while (_match(TokenType.OR)) {
      var op = _previous();
      var right = _and();
      expr = LogicalExpression(expr, op, right);
    }

    return expr;
  }

  Token _peek([int depth = 0]) => _tokens[_current + depth];

  Token _previous() => _tokens[_current - 1];

  Expression _primary() {
    if (_match(TokenType.FALSE)) return LiteralExpression(false);
    if (_match(TokenType.TRUE)) return LiteralExpression(true);
    if (_match(TokenType.NULL)) return LiteralExpression(null);

    if (_matchAny([TokenType.NUMBER, TokenType.STRING])) {
      return LiteralExpression(_previous().literal);
    }

    if (_match(TokenType.THIS)) {
      return ThisExpression(_previous());
    }

    if (_match(TokenType.IDENTIFIER)) {
      return VariableExpression(_previous());
    }

    if (_match(TokenType.LEFT_PAREN)) {
      var expr = _expression();
      _consume(TokenType.RIGHT_PAREN, 'Expect \')\' after expression.');
      return GroupingExpression(expr);
    }

    throw _error(_peek(), 'Expect expression.');
  }

  Statement _returnStatement() {
    var keyword = _previous();
    var value;
    if (!_check(TokenType.SEMICOLON)) {
      value = _expression();
    }
    _consume(TokenType.SEMICOLON, 'Expect \';\' after return value.');
    return ReturnStatement(keyword, value);
  }

  Statement _statement() {
    if (_match(TokenType.FOR)) return _forStatement();
    if (_match(TokenType.RETURN)) return _returnStatement();
    if (_match(TokenType.WHILE)) return _whileStatement();
    if (_match(TokenType.IF)) return _ifStatement();
    if (_match(TokenType.LEFT_BRACE)) return BlockStatement(_block());

    return _expressionStatement();
  }

  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == TokenType.SEMICOLON) return;

      switch (_peek().type) {
        case TokenType.CLASS:
        case TokenType.VAR:
        case TokenType.FOR:
        case TokenType.IF:
        case TokenType.WHILE:
        case TokenType.RETURN:
          return;
          break;

        default:
          break;
      }
    }

    _advance();
  }

  Expression _unary() {
    if (_matchAny([TokenType.BANG, TokenType.MINUS])) {
      var op = _previous();
      var right = _unary();
      return UnaryExpression(op, right);
    }
    return _call();
  }

  Statement _varDeclaration() {
    if (_checkSeq(
        [TokenType.IDENTIFIER, TokenType.EQUAL, TokenType.LEFT_PAREN])) {
      return _varFunctionStatement();
    }

    Token name = _consume(TokenType.IDENTIFIER, 'Expect variable name.');

    Expression initializer;
    if (_match(TokenType.EQUAL)) {
      initializer = _expression();
    }

    _consume(TokenType.SEMICOLON, 'Expect \';\' after variable declaration.');
    return VarStatement(name, initializer);
  }

  Statement _varFunctionStatement() {
    var name = _consume(TokenType.IDENTIFIER, 'Expect identifier.');
    _consume(TokenType.EQUAL, 'Expect = after identifier.');
    var function = _functionStatement('function', varToken: name);
    _consume(TokenType.SEMICOLON, 'Expect \';\' after function declaration.');
    return function;
  }

  Statement _whileStatement() {
    _consume(TokenType.LEFT_PAREN, 'Expect \'(\' after \'while\'.');
    var condition = _expression();
    _consume(TokenType.RIGHT_PAREN, 'Expect \')\' after condition.');
    var body = _statement();

    return WhileStatement(condition, body);
  }
}

class ParseError extends Error {
  final Token token;
  final String message;

  ParseError(this.token, this.message);

  @override
  String toString() {
    return '$token: $message';
  }
}
