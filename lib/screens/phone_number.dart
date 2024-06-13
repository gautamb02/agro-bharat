import 'package:agro_bharat/config/constants.dart';
import 'package:agro_bharat/screens/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _verifyPhoneNumber() async {
    // Add your phone number verification logic here
    _otp = _otpController.text.trim();

    if (_otp!.length != 6) {
      const snackdemo = SnackBar(
          content: Text(
            'Enter a Valid OTP!',
            style: TextStyle(fontFamily: 'MuktaLatin'),
          ),
          backgroundColor: Colors.red,
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(5));
      ScaffoldMessenger.of(context).showSnackBar(snackdemo);
      return;
    }

    try {

      if(verificationid==null || _otp == null){
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
          // String uid = user.uid;
          // print("USER ID : " +user.uid);
          // if (userDataSnapshot!=null) {
          //   print("USER SNAP : ${userDataSnapshot['name']}");
          //   String name = userDataSnapshot['name'];
          //   String phoneNumber = userDataSnapshot['phoneNumber'];
          //   String userId = userDataSnapshot['userId'];
          //   UserModel userm = UserModel( name: name, phoneNumber: phoneNumber, userId: userId);
          //
          //   await SharedPreferencesHelper.saveUserData(userm);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => NameInputPage(
          //         phoneNumber: widget.phonenumber,
          //         userId: uid),
          //   ),
          // );
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
            const Text(
              "Enter your Phone",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'MuktaLatin',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You will receive a 6-digit code to verify your phone number",
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
                hintText: 'Phone Number',
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
                  hintText: 'Enter received OTP',
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
                  onPressed: _sendOTP,
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
                  child: const Text(
                    'Send OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            Visibility(
              visible: _showVerifyButton,
              child: ElevatedButton(
                  onPressed: _verifyPhoneNumber,
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
                  child: const Text(
                    'Verify Phone Number',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOTP() async {
    _phoneNumber = _phoneController.text.trim();
    // You can navigate to the next screen or perform any other action
    // based on the verified phone number
    if (_phoneNumber!.length != 10) {
      const snackdemo = SnackBar(
          content: Text(
            'Enter a Valid Phone Number!',
            style: TextStyle(fontFamily: 'MuktaLatin'),
          ),
          backgroundColor: Colors.red,
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(5));
      ScaffoldMessenger.of(context).showSnackBar(snackdemo);
      return;
    }

    String normalizedPhoneNumber = "+91" + _phoneNumber!;
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: normalizedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential) {},
        verificationFailed: (FirebaseAuthException) {},
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
