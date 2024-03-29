English | [简体中文](./README.zh-CN.md)

# Dash - A toy scripting language written in Dart.

[![Build status](https://travis-ci.org/jarontai/dash.svg)](https://travis-ci.org/jarontai/dash)

Dash is an [interpreter](https://en.wikipedia.org/wiki/Interpreter_(computing)) which fully build with [Dart](https://dart.dev). Dash is also a small scripting language with **Dart-like** syntax and features.

Dash is a dart version of [Crafting Interpreters](http://craftinginterpreters.com/), which is a great tutorial of interpreter/language implementation.

## Current Status

The dash interpreter is almost done, the next is implementing the bytecode vm in [Rust](https://www.rust-lang.org/)!

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

## Run REPL

<p align="left">
<kbd>
  <img src="https://raw.github.com/jarontai/dash/master/dash-repl.gif">
</kbd>
</p>

## Run dash file

Save your dash code in a file, then pass it to bin/dash

    $ dart bin/dash.dart example/hello.dash

## Test

    $ pub run test
