English | [简体中文](./README.zh-CN.md)

# Dash - A tiny interpreter written in Dart.

[![Build status](https://travis-ci.org/jarontai/dash.svg)](https://travis-ci.org/jarontai/dash)

Dash is an interpreter which fully build with [Dart](https://dart.dev). Dash is also a small dynamic language with Dart-like syntax and features.

Dash is a dartify version of [Crafting Interpreters](http://craftinginterpreters.com/), which is a great book of interpreter/language implementation.

## Language

The Dash language features:

  * Dart-like syntax and keywords
  * intergers, doubles and arithmetic expressions
  * booleans and string
  * functions and closures
  * class and inheritance
  * native functions: print

  ``` dart
    // Dash code example
    var one = 1;
    var two = 2;
    var add = (x, y) {
      return x + y;
    };
    var times = add(one, two);

    if (times >= 3) {
      print('Dash!!!');
    } else {
      print('Dash!');
    }

    while (times <= 10) {
      print(times);
      times = times + 1;
    } 

    class Base {
      sayHi() {
        print('Hello ' + this.name);
      }
    }

    class Dash extends Base {
      sayHi() {
        for (var i = 0; i < this.times; i = i + 1) {
          super.sayHi();
        }
      }
    }

    var dash = Dash();
    dash.name = 'dash';
    dash.times = times;
    dash.sayHi();
  ```

## Interpreter

The Dash interpreter is build to parse the Dash language, which includes following:

  * the scanner (lexer/tokenizer)
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
