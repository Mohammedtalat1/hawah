import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Position? _currentPosition;
  double? _qiblaBearing;
  double _heading = 0.0;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initLocationAndCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndCompass() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await QiblaService.determinePosition();
      final bearing = QiblaService.calculateQiblaBearing(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
        _qiblaBearing = bearing;
        _isLoading = false;
      });

      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (mounted && event.heading != null) {
          setState(() {
            _heading = event.heading!;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة الشريفة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة التحديد',
            onPressed: _initLocationAndCompass,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحديد موقعك وحساب اتجاه القبلة...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _initLocationAndCompass,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildCompassView(),
    );
  }

  Widget _buildCompassView() {
    final bearing = _qiblaBearing ?? 0.0;
    // Calculate angle to Kaaba relative to phone's current direction
    final relativeAngle = QiblaService.calculateRelativeAngle(_heading, bearing);
    final isFacingQibla = relativeAngle.abs() < 4.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isFacingQibla ? AppColors.success.withAlpha(30) : AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isFacingQibla ? AppColors.success : AppColors.primary.withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFacingQibla ? Icons.check_circle : Icons.navigation,
                    color: isFacingQibla ? AppColors.success : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFacingQibla
                        ? 'أنت باتجاه الكعبة المشرفة الآن'
                        : 'زاوية القبلة: ${bearing.toStringAsFixed(1)}°',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isFacingQibla ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Animated Compass Dial
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass background dial rotating with phone heading
                  Transform.rotate(
                    angle: -_heading * (math.pi / 180.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: AppColors.primary.withAlpha(80), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(20),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('ش (N)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('ج (S)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('غ (W)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('ش (E)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                          ),
                          // Kaaba needle inside the rotating compass
                          Transform.rotate(
                            angle: bearing * (math.pi / 180.0),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 24),
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.mosque, color: Colors.white, size: 20),
                                  ),
                                  Container(
                                    width: 3,
                                    height: 70,
                                    color: AppColors.secondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center indicator dot
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Calibration advice
            const Text(
              'قم بتحريك الجهاز على شكل الرقم 8 لمعايرة البوصلة إن لزم الأمر',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
