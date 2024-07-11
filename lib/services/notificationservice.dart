

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/servicecontrol/v1.dart' as serviceControl;
import 'dart:async';

class FCMService {


  static Future<String?> getFcmToken({
    int maxRetries = 3,
    Duration retryInterval = const Duration(seconds: 5)
  }) async {
    int retryCount = 0;
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    while (retryCount < maxRetries) {
      try {
        String? token = await messaging.getToken();
        if (token != null) {
          return token;
        }
      } catch (e) {
        print("Token retrieval failed: $e. Attempt ${retryCount + 1} of $maxRetries");
      }

      retryCount  = retryCount + 1;
      if (retryCount < maxRetries) {
        await Future.delayed(retryInterval);
      }
    }

    print("Failed to retrieve FCM token after $maxRetries attempts");
    return null;
  }

}
