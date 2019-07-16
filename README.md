English | [简体中文](./README.zh-CN.md)

# Dash - A tiny interpreter written in Dart.

Dash is an interpreter fully build with [Dart](https://dart.dev). Dash is also a small dynamic language which is a subset of the [Dart](https://dart.dev) language.

Dash is a dartify version of [Bob Nystrom](https://github.com/munificent)'s [Crafting Interpreters](http://craftinginterpreters.com/), which is a great book of interpreter/language implementation.

## Language

The Dash language features:

  * Dart-like syntax and keywords
  * arithmetic expressions
  * intergers, doubles and booleans
  * string, array and map
  * functions and closures

  ``` dart
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

  * the lexer (scanner)
  * the AST (Abstract Syntax Tree)
  * the parser
  * the evaluator

## Run REPL

    $ dart bin/dash.dart
    >> 2 * 5 + 10
    20
    >> var a = 1; var b = 2; a + b;
    3
    >> a
    1
    >> c
    identifier not found: c
    ......
    

## Test

    $ pub run test
