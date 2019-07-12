import 'dart:io';

// The ast generating script

final Map<String, String> astMap = {
  'BinaryExpression': 'Expression left, Token op, Expression right',
  'GroupingExpression': 'Expression expression',
  'LiteralExpression': 'Object value',
  'UnaryExpression': 'Token op, Expression right'
};

final String baseName = 'Expression';

main(List<String> args) {
  var sb = StringBuffer();

  sb.writeln("import '../scanning/token.dart';");

  sb.writeln();

  sb.writeln('abstract class $baseName {');

  sb.writeln(
    'R accept<R>(Visitor<R> visitor);');

  sb.writeln('}');

  for (var entry in astMap.entries) {
    var className = entry.key;
    var fields = entry.value;

    sb.writeln();
    sb.writeln('class $className extends $baseName {');

    fields.split(',').forEach((field) {
      sb.writeln('final $field;');
    });

    var args = fields.split(',').map((field) {
      return 'this.${field.trim().split(' ')[1]}';
    }).join(',');
    sb.writeln('$className($args);');

    sb.writeln();

    sb.writeln(
        'R accept<R>(Visitor<R> visitor) {');
    sb.writeln('return visitor.visit$className(this);');
    sb.writeln('}');

    sb.writeln('}');

    sb.writeln();
  }

  sb.writeln('abstract class Visitor<R> {');
  astMap.keys.forEach((className) {
    sb.writeln(
        'R visit$className($className ${baseName.toLowerCase()});');
  });
  sb.writeln('}');

  var file = File('./lib/src/parsing/expression.dart');
  file.writeAsStringSync(sb.toString());
}
