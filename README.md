# Dash - A toy language & interpreter written in Dart.

Dash is both an interpreter and a language. Dash is fully build with [Dart](https://dart.dev) and <3.

## Language

The little Dash language is a subset of the [Dart](https://dart.dev) language, which includes features as follow:

  * C-like syntax and keywords
  * arithmetic expressions
  * intergers, doubles and booleans
  * string, array and map
  * functions and closures

  ```
    // Dash code

    var one = 1;
    var tpf = 2.5;

    var add = (x, y) {
      return x + y;
    };

    var result = add(one, tpf);
  ```

## Interpreter

The Dash interpreter is build to parse the Dash language, which includes following:

  * the lexer
  * the parser
  * the AST (Abstract Syntax Tree)
  * the evaluator

## Run REPL

    $ pub run bin/repl
    

## Test

    $ pub run test

## References

  * [Writing An Interpreter In Go](https://interpreterbook.com/)
  * [I wrote a programming language. Here’s how you can, too.](https://www.freecodecamp.org/news/the-programming-language-pipeline-91d3f449c919/)


Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
