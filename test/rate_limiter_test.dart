import 'package:rate_limiter/rate_limiter.dart';
import 'package:rate_limiter/src/extention.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final awesomeFunc = limited(()=>print('limiter here'), [Limit(1000, 1),Limit(60000, 10)]);

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(awesomeFunc, isTrue);
    });
  });
}
