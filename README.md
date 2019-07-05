# Dash - A tiny interpreter written in Dart.

Dash is an interpreter fully build with [Dart](https://dart.dev). Dash is also a small dynamic language which is a subset of the [Dart](https://dart.dev) language.

## Language

The Dash language features:

  * C-like syntax and keywords
  * arithmetic expressions
  * intergers, doubles and booleans
  * string, array and map
  * functions and closures

  ```
    // Dash code

    var one = 1;
    var two = 2;

    var add = (x, y) {
      return x + y;
    };

    var result = add(one, two);
  ```

## Interpreter

The Dash interpreter is build to parse the Dash language, which includes following:

  * the lexer
  * the parser
  * the AST (Abstract Syntax Tree)
  * the evaluator

## Run REPL

    $ pub run bin/dash
    >> 2 * 5 + 10
    20
    >> var a = 1; var b = 2; a + b;
    3
    ......
    

## Test

    $ pub run test

## References

Dash is an dartify version of [Writing An Interpreter In Go](https://interpreterbook.com/), which is a great book of interpreter implementation.
