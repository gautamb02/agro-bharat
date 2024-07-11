import 'package:agro_bharat/config/constants.dart';
import 'package:agro_bharat/screens/homescreen.dart';
import 'package:agro_bharat/screens/signupscreen.dart';
import 'package:agro_bharat/services/firestoreservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({Key? key}) : super(key: key);

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  bool _showOTPField = false;
  bool _showVerifyButton = false;
  bool _showOtpButton = true;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _phoneNumber;
  String? verificationid;
  String? _otp;
  FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _verifyPhoneNumber(BuildContext context) async {
    // Add your phone number verification logic here
    _otp = _otpController.text.trim();

    if (_otp!.length != 6) {
      final snackdemo = SnackBar(
        content: Text(
          AppLocalizations.of(context)!.enterValidOTP,
          style: TextStyle(fontFamily: 'MuktaLatin'),
        ),
        backgroundColor: Colors.red,
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackdemo);
      return;
    }

    try {
      if (verificationid == null || _otp == null) {
        return;
      }
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationid ?? '',
        smsCode: _otp ?? '',
      );

      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) async {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String uid = user.uid;
          DocumentSnapshot<Object?>? userDataSnapshot =
          await _firestoreService.getUserDataByPhoneNumber(_phoneNumber!);
          if (userDataSnapshot != null) {
            print("USER SNAP : ${userDataSnapshot['name']}");
            await _firestoreService.updateUserFcmToken(uid);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUpScreen(
                    phoneNumber: _phoneNumber ?? "",
                    userId: uid
                ),
              ),
            );
          }
        }
      });
    } catch (ex) {
      print(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Text(
              AppLocalizations.of(context)!.enterYourPhone,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'MuktaLatin',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.sixDigitCodeInfo,
              style: TextStyle(
                fontFamily: 'MuktaLatin',
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              cursorColor: Colors.black,
              style:
                  TextStyle(fontFamily: 'MuktaLatin', height: 1, fontSize: 19),
              decoration: InputDecoration(
                iconColor: Colors.black,
                hintText: AppLocalizations.of(context)!.phoneNumber,
                filled: true,
                fillColor: AppConstants.cardBackgroundColor,
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: _showOTPField,
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                cursorColor: Colors.black,
                style: TextStyle(
                    fontFamily: 'MuktaLatin', height: 1, fontSize: 19),
                decoration: InputDecoration(
                  iconColor: Colors.black,
                  hintText: AppLocalizations.of(context)!.enterReceivedOTP,
                  filled: true,
                  fillColor: AppConstants.cardBackgroundColor,
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: _showOtpButton,
              child: ElevatedButton(
                  onPressed:  () => _sendOTP(context),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppConstants.primaryGreen),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(10)),
                      textStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          fontFamily: 'MuktaLatin'))),
                  child:  Text(
                    AppLocalizations.of(context)!.sendOTP,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            Visibility(
              visible: _showVerifyButton,
              child: ElevatedButton(
                  onPressed: () => _verifyPhoneNumber(context),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppConstants.primaryGreen),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(10)),
                      textStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          fontFamily: 'MuktaLatin'))),
                  child:  Text(
                    AppLocalizations.of(context)!.verifyPhoneNumber,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOTP(BuildContext context) async {
    _phoneNumber = _phoneController.text.trim();
    // You can navigate to the next screen or perform any other action
    // based on the verified phone number
    if (_phoneNumber!.length != 10) {
      final snackdemo = SnackBar(
        content: Text(
          AppLocalizations.of(context)!.enterValidPhoneNumber,
          style: TextStyle(fontFamily: 'MuktaLatin'),
        ),
        backgroundColor: Colors.red,
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackdemo);
      return;
    }

    _phoneNumber = "+91" + _phoneNumber!;
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            verificationid = verificationId;
            _showOTPField = true;
            _showVerifyButton = true;
            _showOtpButton = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      print("Error sending OTP: $e");
      // Handle error sending OTP
    }
  }

}
