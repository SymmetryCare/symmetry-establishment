import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/firebase_options.dart';
import 'package:symmetry_establishment/services/device_notification_service.dart';

Future<void> initFCM({
  required String deviceName,
  required BuildContext context,
}) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final settings = await FirebaseMessaging.instance.requestPermission();
    debugPrint(
      'Notification permission: ${settings.authorizationStatus}',
    );

    final token = await FirebaseMessaging.instance.getToken(
      vapidKey:
          'BGYuerYf4fJiJClBiWmQIqb7U-fI7Bb9eLFjh-1abp9SgfdWDUr1B1upiIXwTq6ZDkr0qUZmnJwh1B3by2520U8',
    );
    if (token == null || token.isEmpty) {
      debugPrint('FCM token unavailable; continuing without notifications.');
      return;
    }

    final response = await addRegisterDevice(
      userId: await TokenManager.getuserId(),
      fcmToken: token,
      deviceType: 'WEB',
      deviceName: deviceName.isEmpty ? 'Web browser' : deviceName,
      context: context,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      TokenManager.setFcmToken(fcmToken: token);
      debugPrint('Device registered for notifications.');
    } else {
      debugPrint(
        'Device notification registration failed: ${response.message}',
      );
    }
  } catch (error) {
    debugPrint(
      'Firebase messaging unavailable; continuing login: $error',
    );
  }
}
