English | [简体中文](./README.zh-CN.md)

# Dash - A tiny interpreter written in Dart.

Dash is an interpreter which fully build with [Dart](https://dart.dev). Dash is also a small dynamic language with Dart-like syntax and features.

Dash is a dartify version of [Crafting Interpreters](http://craftinginterpreters.com/), which is a great book of interpreter/language implementation.

## Language

The Dash language features:

  * Dart-like syntax and keywords
  * intergers, doubles and arithmetic expressions
  * booleans and string
  * functions and closures
  * classes
  * native functions: print

  ``` dart
    // Dash code example
    var one = 1;
    var two = 2;
    var add = (x, y) {
      return x + y;
    };
    var result = add(one, two);

    class Dash {
      sayHi() {
        print('Hello ' + this.name);
      }
    }
    var dash = Dash();
    dash.name = 'dash';
    dash.sayHi();
  ```

## Interpreter

The Dash interpreter is build to parse the Dash language, which includes following:

  * the scanner (lexer)
  * the AST (Abstract Syntax Tree)
  * the parser
  * the interpreter (evaluator)

## Run dash code file

Save your dash code in a file, then pass it to bin/dash

    $ dart bin/dash.dart example/hello.dash

## Run REPL

    $ dart bin/dash.dart
    >> 2 * 5 + 10;
    20
    >> var sayHi = (name) { return 'hello ' + name; };
    <function sayHi>
    >> sayHi('dart');
    hello dart
    ......
    

## Test

    $ pub run test
