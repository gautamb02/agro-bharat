import 'package:agro_bharat/components/language_button.dart';
import 'package:agro_bharat/config/constants.dart';
import 'package:agro_bharat/screens/homescreen.dart';
import 'package:agro_bharat/screens/phone_number.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Hindi',
    'Spanish',
    'French',
    'German'
  ];

  @override
  void initState() {
    super.initState();
    // Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Navigate to HomeScreen if logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    }
  }
  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Image.asset("assets/images/logo.png", height: 120)),
            ..._languages.map((language) {
              final isSelected = language == _selectedLanguage;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: LanguageButton(
                  languageName: language,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 20,),
            SizedBox(

              height: 40,
              width: (MediaQuery.of(context).size.width *
                  0.6),
              child: Container(
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen,
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () {

                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const PhoneNumberScreen()));
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'MuktaLatin',
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
