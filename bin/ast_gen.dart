import 'dart:io';

import 'package:dash/src/parser/ast_gen.dart' as generator;

main(List<String> args) {
  var file = File('./lib/src/parser/ast.dart');
  file.writeAsStringSync(generator.run());
}
