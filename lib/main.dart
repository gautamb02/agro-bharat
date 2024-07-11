import 'package:agro_bharat/screens/alert.dart';
import 'package:agro_bharat/screens/homescreen.dart';
import 'package:agro_bharat/screens/language_screen.dart';
import 'package:agro_bharat/services/notificationservice.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
  // The app will handle this message when it's opened
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  requestNotificationPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen(_handleMessage);

  // Handle when the app is opened from a background state
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

  // Check for initial message (app opened from terminated state)
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? token = await FCMService.getFcmToken();
  print(token);

  runApp(const MyApp());
}

void _handleMessage(RemoteMessage message) {
  if (message.notification != null) {
    print('Notification: ${message.notification}');
    // Delay the navigation slightly to ensure the app is fully initialized
    Future.delayed(Duration(milliseconds: 100), () {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => AlertScreen(message: message)),
      );
    });
  }
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "MuktaLatin",
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
