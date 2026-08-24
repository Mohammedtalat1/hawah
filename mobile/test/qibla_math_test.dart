import 'package:flutter_test/flutter_test.dart';
import 'package:hawah/core/services/qibla_service.dart';

void main() {
  group('Qibla Bearing Calculation Tests', () {
    test('Bearing from Cairo (30.0444, 31.2357) to Mecca should be approximately 136 degrees', () {
      final bearing = QiblaService.calculateQiblaBearing(30.0444, 31.2357);
      expect(bearing, greaterThan(130.0));
      expect(bearing, lessThan(142.0));
    });

    test('Bearing from London (51.5074, -0.1278) to Mecca should be approximately 119 degrees', () {
      final bearing = QiblaService.calculateQiblaBearing(51.5074, -0.1278);
      expect(bearing, greaterThan(115.0));
      expect(bearing, lessThan(125.0));
    });

    test('Bearing from Jakarta (-6.2088, 106.8456) to Mecca should be approximately 295 degrees', () {
      final bearing = QiblaService.calculateQiblaBearing(-6.2088, 106.8456);
      expect(bearing, greaterThan(290.0));
      expect(bearing, lessThan(300.0));
    });

    test('Relative angle calculation handles 360 wrap around correctly', () {
      // Facing 130 deg, Qibla at 135 deg -> diff +5 deg (turn right)
      final diff1 = QiblaService.calculateRelativeAngle(130.0, 135.0);
      expect(diff1, closeTo(5.0, 0.001));

      // Facing 355 deg, Qibla at 5 deg -> diff +10 deg (turn right across North)
      final diff2 = QiblaService.calculateRelativeAngle(355.0, 5.0);
      expect(diff2, closeTo(10.0, 0.001));

      // Facing 10 deg, Qibla at 350 deg -> diff -20 deg (turn left across North)
      final diff3 = QiblaService.calculateRelativeAngle(10.0, 350.0);
      expect(diff3, closeTo(-20.0, 0.001));
    });
  });
}
