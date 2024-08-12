import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:agro_bharat/config/constants.dart';

class AddCow extends StatefulWidget {
  const AddCow({Key? key}) : super(key: key);

  @override
  State<AddCow> createState() => _AddCowState();
}

class _AddCowState extends State<AddCow> {
  final _formKey = GlobalKey<FormState>();
  final _cowIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _linkCowToFarmer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final farmerId = user.uid;
        final cowId = _cowIdController.text;

        try {
          final response = await http.post(
            Uri.parse(
                '${AppConstants.COW_SENSOR_BASE_URL}/linkCowToFarmer/$farmerId/$cowId'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );

          print(response.body);

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.cowLinkedSuccessfully)),
            );
            _cowIdController.clear();
          } else {
            throw Exception(AppLocalizations.of(context)!.failedToLinkCow);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${AppLocalizations.of(context)!.error} ${e.toString()}')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.userNotLoggedIn)),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 5,
        centerTitle: true,
        backgroundColor: AppConstants.primaryGreen,
        title: Text(AppLocalizations.of(context)!.addCow,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/images/cow_icon.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 40),
                  Text(
                    AppLocalizations.of(context)!.linkNewCow,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _cowIdController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.cowID,
                      hintText: AppLocalizations.of(context)!.enterUniqueCowID,
                      prefixIcon: Icon(Icons.tag, color: Colors.blue[300]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.blue[500]!, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterCowID;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _linkCowToFarmer,
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.linkCowToFarmer),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue[400],
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cowIdController.dispose();
    super.dispose();
  }
}
