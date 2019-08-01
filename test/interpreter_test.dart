import 'package:dash/dash.dart';
import 'package:test/test.dart';

void main() {
  Object interprete(String input) {
    var tokens = Scanner(input).scanTokens();
    var stmts = Parser(tokens).parse();
    var interpreter = Interpreter();
    return interpreter.interprete(stmts);
  }

  test('basic expressions', () {
    var inputs = [
      '1;',
      '2;',
      '"string";',
      'false;',
      'true;',
      '1 + 2;',
      '1 + 2 / 1 + 3;',
      '1 + 2 / (1 + 3);',
      '1 > 2;',
      '1 < 2;',
      '1 <= 2;',
      '1 >= 2;',
    ];

    var expects = [
      1,
      2,
      'string',
      false,
      true,
      3,
      6,
      1.5,
      false,
      true,
      true,
      false,
    ];
    for (var i = 0; i < inputs.length; i++) {
      var result = interprete(inputs[i]);

      expect(result, expects[i]);
    }
  });

  test('var statements', () {
    var inputs = [
      'var one = 1;',
      'var two = 2;',
      'var string = "string";',
    ];

    var expects = [
      1,
      2,
      'string',
    ];

    for (var i = 0; i < inputs.length; i++) {
      var result = interprete(inputs[i]);
      expect(result, expects[i]);
    }
  });

  test('assign statements', () {
    var inputs = [
      'var one = 1; one = 2;',
      'var string = "string"; string = "hello";',
    ];

    var expects = [2, 'hello'];

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var result = interprete(input);
      expect(result, expects[i]);
    }
  });

  test('block statements', () {
    var inputs = [
      '{ var one = 1; one = 2; } ',
      '{ var string = "string"; string = "hello"; }',
      '{ var one = 1; one = 2; } var one = 3;',
      'var one = 1; var string = "hi"; { var string = "string"; string = "hello"; } string = "what";',
    ];

    var expects = [2, 'hello', 3, 'what'];

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var result = interprete(input);
      expect(result, expects[i]);
    }
  });

  test('if statements', () {
    var inputs = [
      'var one = 1; if (one >= 1) { one = 2; } else { one = 3; }',
      'var one = 1; if (one < 1) { one = 2; } else { one = 3; }',
    ];

    var expects = [2, 3];

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var result = interprete(input);
      expect(result, expects[i]);
    }
  });

  test('logical', () {
    var inputs = [
      'var one = 1; if (one < 1 && false) { one = 2; } else { one = 3; }',
      'var one = 1; if (one >= 1 && true) { one = 2; } else { one = 3; }',
    ];

    var expects = [3, 2];

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var result = interprete(input);
      expect(result, expects[i]);
    }
  });

  test('while loop', () {
    var inputs = [
      'var one = 1; while (one < 10) { one = one + 1; } ',
    ];

    var expects = [10];

    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      var result = interprete(input);
      expect(result, expects[i]);
    }
  });

  test('for loop', () {
    var inputs = [
      '''
        var a = 0;
        var b = 1;

        while (a < 100) {
          var temp = a;
          a = b;
          b = temp + b;
        }
      '''
    ];

    var expects = [233];

    for (var i = 0; i < inputs.length; i++) {
      var result = interprete(inputs[i]);
      expect(result, expects[i]);
    }
  });

  test('print function', () {
    var inputs = [
      '''
        var a = 1;
        var b = 2;

        print(a + b);
      '''
    ];

    var expects = [null];

    for (var i = 0; i < inputs.length; i++) {
      var result = interprete(inputs[i]);
      expect(result, expects[i]);
    }
  });  

  test('function', () {
    var inputs = [
      '''
        sayHi(first, last) {
          var result = "Hi, " + first + " " + last + "!";
          print(result);
          return result;
        }

        var t = sayHi('one', 'two');
      '''
    ];

    var expects = ['Hi, one two!'];

    for (var i = 0; i < inputs.length; i++) {
      var result = interprete(inputs[i]);
      expect(result, expects[i]);
    }
  });

  test('closure', () {
    var inputs = [
      '''
        makeAdder(num) {
          var adder = (inputNum) {
            return num + inputNum;
          };
          return adder;
        }

        var add2 = makeAdder(2);
        var result = add2(3);
      '''
    ];

    var expects = [5];

    for (var i = 0; i < inputs.length; i++) {
      var result = interprete(inputs[i]);
      expect(result, expects[i]);
    }
  });

  test('class', () {
    var inputs = [
      '''
        class Test {
          sayHi(name) {
            return 'Hello ' + name;
          }

          echo(name) {
            print(name);
          }          
        }

        Test().sayHi('jojo');
      '''
    ];

    var expects = ['Hello jojo'];

    for (var i = 0; i < inputs.length; i++) {
      var result = interprete(inputs[i]);
      expect(result, expects[i]);
    }
  });
}
