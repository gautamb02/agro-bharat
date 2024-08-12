import 'package:agro_bharat/provider/cow_locations.dart';
import 'package:agro_bharat/screens/alert.dart';
import 'package:provider/provider.dart';
import 'package:agro_bharat/screens/language_screen.dart';
import 'package:agro_bharat/provider/locale_provider.dart';
import 'package:agro_bharat/services/notificationservice.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await requestNotificationPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  FirebaseMessaging.onMessage.listen(_handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? token = await FCMService.getFcmToken();
  print(token);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => CowLocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

void _handleMessage(RemoteMessage message) {
  if (message.notification != null) {
    print('Notification: ${message.notification}');
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
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('mr', ''), // Marathi
            Locale('hi', ''), // Hindi
          ],
          locale: localeProvider.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },

          navigatorKey: navigatorKey,
          title: 'Agro Bharat',
          theme: ThemeData(
            fontFamily: "Inter",
            useMaterial3: true,
          ),
          home: LanguageSelectionScreen(),
        );
      },
    );
  }
}