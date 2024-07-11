import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  final RemoteMessage message;

  const AlertScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alert Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Notification Title: ${message.notification?.title ?? "No title"}'),
            SizedBox(height: 20),
            Text('Notification Body: ${message.notification?.body ?? "No body"}'),
            SizedBox(height: 20),
            if (message.data.isNotEmpty)
              Text('Additional Data: ${message.data}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}