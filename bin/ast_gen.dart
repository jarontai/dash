import 'dart:io';

import 'package:dart_style/dart_style.dart';

final Map<String, Map<String, String>> astMap = {
  'Expression': {
    'BinaryExpression': 'Expression left, Token op, Expression right',
    'GroupingExpression': 'Expression expression',
    'LiteralExpression': 'Object value',
    'UnaryExpression': 'Token op, Expression right',
    'VariableExpression': 'Token name',
  },
  'Statement': {
    'ExpressionStatement': 'Expression expression',
    'VarStatement': 'Token name, Expression initializer',
  },  
};

main(List<String> args) {
  var sb = StringBuffer();

  sb.writeln(
      '// These code was generated by ast_gen, so please don\'t modify directly.');

  sb.writeln();

  sb.writeln("import '../scanning/token.dart';");

  sb.writeln();

  sb.writeln('// The ast expressions.');

  sb.writeln();

  for (var baseName in astMap.keys) {
    sb.writeln('abstract class $baseName {');

    sb.writeln('R accept${baseName}<R>(${baseName}Visitor<R> visitor);');

    sb.writeln('}');

    for (var entry in astMap[baseName].entries) {
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

      sb.writeln('R accept${baseName}<R>(${baseName}Visitor<R> visitor) {');
      sb.writeln('return visitor.visit$className(this);');
      sb.writeln('}');

      sb.writeln('}');

      sb.writeln();
    }

    sb.writeln('abstract class ${baseName}Visitor<R> {');
    astMap[baseName].keys.forEach((className) {
      sb.writeln('R visit$className($className ${baseName.toLowerCase()});');
    });
    sb.writeln('}');

    sb.writeln();
    sb.writeln();
    sb.writeln();
  }

  var formatter = DartFormatter();
  var file = File('./lib/src/parsing/ast.dart');
  file.writeAsStringSync(formatter.format(sb.toString()));
}
