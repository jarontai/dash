简体中文 | [English](./README.md)

# Dash - 使用Dart实现的简单解释器（Interpreter）

Dash 是一个完全使用 [Dart](https://dart.dev) 实现的简单解释器，它也是一门解释型语言，支持 [Dart](https://dart.dev) 语言的部分基础特性。

Dash 的实现是基于 Dart 项目组成员 [Bob Nystrom](https://github.com/munificent) 的 《[Crafting Interpreters](http://craftinginterpreters.com/)》。

## 语言

Dash 的语言特性包括：

  * Dart-like 的语法和关键字
  * 支持算术表达式，数字和布尔量
  * 支持字符串，数组和map
  * 支持函数和闭包

  ``` dart
    // Dash 代码

    var one = 1;
    var two = 2;

    var add = (x, y) {
      return x + y;
    };

    var result = add(one, two);
  ```

## 解释器

Dash 解释器的主要工作是分析和执行 Dash 语言， 它由以下主要模块组成：

  * 词法分析器 lexer (scanner)
  * 抽象语法树 AST
  * 语法分析器 parser
  * 表达式计算器 evaluator

## 运行 REPL

    $ pub run bin/dash
    >> 2 * 5 + 10
    20
    >> var a = 1; var b = 2; a + b;
    3
    >> a
    1
    >> c
    identifier not found: c
    ......
    

## 测试

    $ pub run test
