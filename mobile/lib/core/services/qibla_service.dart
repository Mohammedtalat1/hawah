import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';
import '../errors/app_error.dart';

/// Accurate mathematical Qibla bearing calculations and sensor/GPS coordination.
class QiblaService {
  /// Calculate great-circle bearing from current coordinates to the Kaaba in Mecca.
  /// Kaaba: Lat 21.4225, Long 39.8262
  static double calculateQiblaBearing(double userLat, double userLng) {
    final double phi1 = _degreesToRadians(userLat);
    final double phi2 = _degreesToRadians(AppConstants.kaabaLatitude);
    final double deltaLambda = _degreesToRadians(AppConstants.kaabaLongitude - userLng);

    final double y = math.sin(deltaLambda) * math.cos(phi2);
    final double x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    double bearingRad = math.atan2(y, x);
    double bearingDeg = _radiansToDegrees(bearingRad);

    // Normalize between 0 and 360 degrees
    return (bearingDeg + 360.0) % 360.0;
  }

  /// Calculates the difference angle between current heading and Qibla direction.
  /// Negative means turn left, positive means turn right.
  static double calculateRelativeAngle(double currentHeading, double qiblaBearing) {
    double diff = qiblaBearing - currentHeading;
    while (diff < -180.0) {
      diff += 360.0;
    }
    while (diff > 180.0) {
      diff -= 360.0;
    }
    return diff;
  }

  /// Fetch user location with permissions check.
  static Future<Position> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw AppError.locationUnavailable('خدمات الموقع غير مفعلة');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw AppError.permission('تم رفض إذن الوصول للموقع');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw AppError.permission('تم رفض إذن الوصول للموقع بشكل دائم');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  static double _degreesToRadians(double degrees) => degrees * (math.pi / 180.0);
  static double _radiansToDegrees(double radians) => radians * (180.0 / math.pi);
}
