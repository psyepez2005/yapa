import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import 'notification_service.dart';

class BroadcastSpyService {
  static Timer? _spyTimer;
  static int _lastKnownBroadcastCount = -1;
  static bool _isRunning = false;

  static void startSpying() {
    if (_isRunning) return;
    _isRunning = true;

    _fetchBroadcasts(isInitial: true);

    _spyTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchBroadcasts();
    });
  }

  static void stopSpying() {
    _spyTimer?.cancel();
    _isRunning = false;
    _lastKnownBroadcastCount = -1;
  }

  static Future<void> _fetchBroadcasts({bool isInitial = false}) async {
    try {
      final dio = await ApiClient.userAuthorized();
      if (dio == null) return;

      final response = await dio.get('/loyalty/broadcasts');
      final List data = response.data['data'] as List;

      final currentCount = data.length;

      if (isInitial) {
        _lastKnownBroadcastCount = currentCount;
        return;
      }

      if (_lastKnownBroadcastCount != -1 && currentCount > _lastKnownBroadcastCount) {
        final newest = data.last;
        final merchantName = newest['merchantName'] ?? 'Un negocio cercano';
        final rawMessage = newest['message'] ?? '';
        final valor = newest['couponValue']?.toString() ?? '?';

        String title = '';
        String body = '';

        if (rawMessage.contains('|')) {
          final parts = rawMessage.split('|');
          title = parts[0].trim();
          body = parts[1].trim();
        } else {
          title = '¡$merchantName te extraña!';
          body = 'Lanzaron una nueva Yapa de \$$valor. ¡Abre tu Radar y encuéntrala!';
        }

        await NotificationService.showNotification(
          id: currentCount,
          title: title,
          body: body,
        );
      }

      _lastKnownBroadcastCount = currentCount;

    } catch (e) {
      debugPrint('Spy error: \$e');
    }
  }
}
