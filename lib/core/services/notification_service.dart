import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Config global
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Inicializar el plugin
    // Se obvia el chequeo en web si no usamos web custom notifications, 
    // local notifications tiene fallback basico.
    if (!kIsWeb) {
      await _notificationsPlugin.initialize(
        initializationSettings,
      );
      
      // Pedir permisos en Android 13+
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      // En Web, evitamos crasher el plugin de local_notifications si no está full adaptado 
      // y sencillamente imprimimos en consola o usamos print (ya que el hackathon es en Chrome
      // usaremos un fallback interno si el usuario usa chrome, aunque el plugin dberia correr).
      debugPrint('🔔 [PUSH NOTIFICATION WEB]: $title - $body');
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'yapa_alerts',
      'Yapa Alerts',
      channelDescription: 'Notificaciones sobre nuevas yapas de tus negocios favoritos',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4A1587),
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
