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

  String parseExpression() {
    var expr;
    try {
      expr = _expression();
    } on ParseError catch (e) {
      print(e);
    }
    return astPrinter.print(expr);
  }

  Expression _expression() {
    return _assignment();
  }

  Expression _equality() {
    var expr = _comparison();
    while (_match([TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL])) {
      var op = _previous();
      var right = _comparison();
      expr = BinaryExpression(expr, op, right);
    }
    return expr;
  }

  Expression _comparison() {
    var expr = _addition();
    while (_match([
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
    while (_match([
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
    while (_match([
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
    if (_match([TokenType.BANG, TokenType.MINUS])) {
      var op = _previous();
      var right = _unary();
      return UnaryExpression(op, right);
    }
    return _primary();
  }

  Expression _primary() {
    if (_match([TokenType.FALSE])) return LiteralExpression(false);
    if (_match([TokenType.TRUE])) return LiteralExpression(true);
    if (_match([TokenType.NULL])) return LiteralExpression(null);

    if (_match([TokenType.NUMBER, TokenType.STRING])) {
      return LiteralExpression(_previous().literal);
    }

    if (_match([TokenType.IDENTIFIER])) {
      return VariableExpression(_previous());
    }

    if (_match([TokenType.LEFT_PAREN])) {
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

  bool _match(List<TokenType> types) {
    for (var type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
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
    return _expressionStatement();
  }

  Statement _expressionStatement() {
    var expr = _expression();
    _consume(TokenType.SEMICOLON, 'Expect \';\' after expression.');
    return ExpressionStatement(expr);
  }

  Statement _declaration() {
    try {
      if (_match([TokenType.VAR])) {
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
    if (_match([TokenType.EQUAL])) {
      initializer = _expression();
    }

    _consume(TokenType.SEMICOLON, 'Expect \';\' after variable declaration.');
    return VarStatement(name, initializer);
  }

  Expression _assignment() {
    var expr = _equality();

    if (_match([TokenType.EQUAL])) {
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
