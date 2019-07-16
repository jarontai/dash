import 'package:dash/dash.dart';
import 'package:test/test.dart';

void main() {
  test('basic expressions', () {
    var inputs = [
      '1',
      '2',
      '"string"',
      'false',
      'true',
      '1 + 2',
      '1 + 2 / 1 + 3',
      '1 + 2 / (1 + 3)',
      '1 > 2',
      '1 < 2',
      '1 <= 2',
      '1 >= 2',
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
      expect(Runner.run(inputs[i], false), expects[i]);
    }
  });
}
