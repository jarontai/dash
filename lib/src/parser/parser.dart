import 'ast.dart';
import 'ast_printer.dart';
import '../scanner/token.dart';
import '../runner.dart';

export 'ast.dart';

// The parser, which response for producing ast [Expression]s from [Token]s.
class Parser {
  final List<Token> _tokens;
  int _current = 0;
  static final AstPrinter astPrinter = AstPrinter();

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
      Runner.parseError(e);
    }
    return stmts;
  }

  Expression _expression() {
    return _assignment();
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

  Expression _unary() {
    if (_matchAny([TokenType.BANG, TokenType.MINUS])) {
      var op = _previous();
      var right = _unary();
      return UnaryExpression(op, right);
    }
    return _primary();
  }

  Expression _primary() {
    if (_matchOne(TokenType.FALSE)) return LiteralExpression(false);
    if (_matchOne(TokenType.TRUE)) return LiteralExpression(true);
    if (_matchOne(TokenType.NULL)) return LiteralExpression(null);

    if (_matchAny([TokenType.NUMBER, TokenType.STRING])) {
      return LiteralExpression(_previous().literal);
    }

    if (_matchOne(TokenType.IDENTIFIER)) {
      return VariableExpression(_previous());
    }

    if (_matchOne(TokenType.LEFT_PAREN)) {
      var expr = _expression();
      _consume(TokenType.RIGHT_PAREN, 'Expect \')\' after expression.');
      return GroupingExpression(expr);
    }

    throw _error(_peek(), 'Expect expression.');
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();

    throw _error(_peek(), message);
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

  bool _matchOne(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  Token _previous() => _tokens[_current - 1];

  bool _isAtEnd() => _peek().type == TokenType.EOF;

  Token _peek() => _tokens[_current];

  ParseError _error(Token token, String message) {
    return ParseError(token, message);
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

  Statement _statement() {
    if (_matchOne(TokenType.FOR)) return _forStatement();
    if (_matchOne(TokenType.WHILE)) return _whileStatement();
    if (_matchOne(TokenType.IF)) return _ifStatement();
    if (_matchOne(TokenType.LEFT_BRACE)) return BlockStatement(_block());

    return _expressionStatement();
  }

  Statement _expressionStatement() {
    var expr = _expression();
    _consume(TokenType.SEMICOLON, 'Expect \';\' after expression.');
    return ExpressionStatement(expr);
  }

  Statement _declaration() {
    try {
      if (_matchOne(TokenType.VAR)) {
        return _varDeclaration();
      }

      return _statement();
    } on ParseError catch (e) {
      _synchronize();
      Runner.parseError(e);
      return null;
    }
  }

  Statement _varDeclaration() {
    Token name = _consume(TokenType.IDENTIFIER, 'Expect variable name.');

    Expression initializer;
    if (_matchOne(TokenType.EQUAL)) {
      initializer = _expression();
    }

    _consume(TokenType.SEMICOLON, 'Expect \';\' after variable declaration.');
    return VarStatement(name, initializer);
  }

  Expression _assignment() {
    var expr = _or();

    if (_matchAny([TokenType.EQUAL])) {
      var token = _previous();
      var value = _assignment();
      if (expr is VariableExpression) {
        var name = expr.name;
        return AssignExpression(name, value);
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

  Statement _ifStatement() {
    _consume(TokenType.LEFT_PAREN, 'Expect \'(\' after if.');
    var condition = _expression();
    _consume(TokenType.RIGHT_PAREN, 'Expect \')\' after if condition.');

    var thenBranch = _statement();
    var elseBranch;
    if (_matchOne(TokenType.ELSE)) {
      elseBranch = _statement();
    }

    return IfStatement(condition, thenBranch, elseBranch);
  }

  Expression _or() {
    var expr = _and();

    while (_matchOne(TokenType.OR)) {
      var op = _previous();
      var right = _and();
      expr = LogicalExpression(expr, op, right);
    }

    return expr;
  }

  Expression _and() {
    var expr = _equality();

    while (_matchOne(TokenType.AND)) {
      var op = _previous();
      var right = _equality();
      expr = LogicalExpression(expr, op, right);
    }

    return expr;
  }

  Statement _whileStatement() {
    _consume(TokenType.LEFT_PAREN, 'Expect \'(\' after \'while\'.');
    var condition = _expression();
    _consume(TokenType.RIGHT_PAREN, 'Expect \')\' after condition.');
    var body = _statement();

    return WhileStatement(condition, body);
  }

  Statement _forStatement() {
    _consume(TokenType.LEFT_PAREN, 'Expect \'(\' after \'for\'.');

    Statement initializer;
    if (_matchOne(TokenType.SEMICOLON)) {
      initializer = null;
    } else if (_matchOne(TokenType.VAR)) {
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
