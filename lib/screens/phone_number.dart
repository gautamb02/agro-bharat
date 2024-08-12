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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool _showOTPField = false;
  bool _showVerifyButton = false;
  bool _showOtpButton = true;
  bool _isLoading = false;

  String? _phoneNumber;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5),
      ),
    );
  }

  Future<void> _sendOTP() async {
    _phoneNumber = _phoneController.text.trim();
    if (_phoneNumber!.length != 10) {
      _showSnackBar(AppLocalizations.of(context)!.enterValidPhoneNumber, isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _phoneNumber = "+91$_phoneNumber";
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar(e.message ?? "Verification failed", isError: true);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _showOTPField = true;
            _showVerifyButton = true;
            _showOtpButton = false;
            _isLoading = false;
          });
          _showSnackBar("OTP Sent");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("Error sending OTP: $e", isError: true);
    }
  }

  Future<void> _verifyPhoneNumber() async {
    String otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showSnackBar(AppLocalizations.of(context)!.enterValidOTP, isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot<Object?>? userDataSnapshot = await _firestoreService.getUserDataByPhoneNumber(_phoneNumber!);

        if (userDataSnapshot != null) {
          await _firestoreService.updateUserFcmToken(user.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpScreen(
                phoneNumber: _phoneNumber!,
                userId: user.uid,
              ),
            ),
          );
        }
      }
    } catch (e) {
      _showSnackBar("Verification failed: $e", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
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
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.sixDigitCodeInfo,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneController,
                  hintText: AppLocalizations.of(context)!.phoneNumber,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                if (_showOTPField)
                  _buildTextField(
                    controller: _otpController,
                    hintText: AppLocalizations.of(context)!.enterReceivedOTP,
                    icon: Icons.lock,
                    keyboardType: TextInputType.number,
                  ),
                const SizedBox(height: 20),
                if (_showOtpButton)
                  _buildButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    text: AppLocalizations.of(context)!.sendOTP,
                  ),
                if (_showVerifyButton)
                  _buildButton(
                    onPressed: _isLoading ? null : _verifyPhoneNumber,
                    text: AppLocalizations.of(context)!.verifyPhoneNumber,
                  ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryGreen),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: Colors.black,
      style: TextStyle(fontFamily: 'Inter', height: 1, fontSize: 19),
      decoration: InputDecoration(
        iconColor: Colors.black,
        hintText: hintText,
        filled: true,
        fillColor: AppConstants.cardBackgroundColor,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildButton({required VoidCallback? onPressed, required String text}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppConstants.primaryGreen),
        padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
        textStyle: MaterialStateProperty.all(const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          fontFamily: 'Inter',
        )),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}