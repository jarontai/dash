简体中文 | [English](./README.md)

# Dash - 使用Dart实现的简单脚本语言

[![Build status](https://travis-ci.org/jarontai/dash.svg)](https://travis-ci.org/jarontai/dash)

Dash 是一个使用 [Dart](https://dart.dev) 实现的简单[解释器](https://baike.baidu.com/item/%E8%A7%A3%E9%87%8A%E5%99%A8)，同时也是一门脚本语言，具备接近于 [Dart](https://dart.dev) 的语法和语言特性。

Dash 的实现是基于 Dart 项目组成员 [Bob Nystrom](https://github.com/munificent) 的 《[Crafting Interpreters](http://craftinginterpreters.com/)》。

## 项目状态

解释器已经基本完成，下一步的计划是使用 [Rust](https://www.rust-lang.org/) 来编写 Dash 的字节码虚拟机!

## 语言

Dash 的语言特性包括：

  * 类似于Dart的语法和关键字
  * 支持数字和算术表达式
  * 支持布尔量、字符串
  * 支持函数和闭包
  * 支持类和继承
  * 内置函数，如：print

  ``` dart
    // Dash 示例代码
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

## 解释器

Dash 解释器的主要工作是分析和执行 Dash 语言， 它由以下主要模块组成：

  * 词法分析器 scanner (lexer/tokenizer)
  * 抽象语法树 AST
  * 语法分析器 parser
  * 解释器 interpreter (evaluator)

## 运行 Dash 代码

将 Dash 代码保存为文件，然后使用 bin/dash 运行

    $ dart bin/dash.dart example/hello.dash

## 运行 REPL

<p align="left">
<kbd>
  <img src="https://raw.github.com/jarontai/dash/master/dash-repl.gif">
</kbd>
</p>
    

## 测试

    $ pub run test
