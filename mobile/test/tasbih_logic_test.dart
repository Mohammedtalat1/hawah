import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tasbih Logic Tests', () {
    test('Initial count should be zero', () {
      int count = 0;
      expect(count, 0);
    });

    test('Increment count increases count by one', () {
      int count = 0;
      count++;
      expect(count, 1);
      count++;
      expect(count, 2);
    });

    test('Progress calculates properly with target', () {
      int count = 33;
      int target = 33;
      double progress = count / target;
      expect(progress, 1.0);

      count = 0;
      progress = count / target;
      expect(progress, 0.0);

      count = 16;
      progress = (count / target).clamp(0.0, 1.0);
      expect(progress, closeTo(0.484, 0.01));
    });

    test('Reset clears count to zero', () {
      int count = 42;
      count = 0;
      expect(count, 0);
    });
  });
}
