import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthenticationService {
  static void sentOtp(String phonenumber) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phonenumber,
        verificationCompleted: (PhoneAuthCredential) {

        },
        verificationFailed: (FirebaseAuthException) {

        },
        codeSent: (String verificationId, int? resendToken) {

        },
        codeAutoRetrievalTimeout: (String verificationId) {

        },
      );
    } catch (e) {
      print("Error sending OTP: $e");
      // Handle error sending OTP
    }
  }
}
