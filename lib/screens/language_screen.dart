import 'package:agro_bharat/components/language_button.dart';
import 'package:agro_bharat/config/constants.dart';
import 'package:agro_bharat/screens/homescreen.dart';
import 'package:agro_bharat/screens/phone_number.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final Function(Locale) setLocale;

  const LanguageSelectionScreen({Key? key, required this.setLocale}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिंदी'},
    {'code': 'mr', 'name': 'मराठी'},
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
                child: Image.asset("assets/images/splashimage_small.png", height: 60)),
            Text(AppLocalizations.of(context)!.selectLanguage,style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 20,),
            ..._languages.map((language) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: LanguageButton(
                  languageName: language['name']!,
                  isSelected: language['code'] == _selectedLanguage,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language['code']!;
                      widget.setLocale(Locale(_selectedLanguage)); // Set locale when language is selected
                    });
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 20,),
            SizedBox(
              height: 40,
              width: (MediaQuery.of(context).size.width * 0.6),
              child: Container(
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const PhoneNumberScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.next,
                    style: const TextStyle(
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