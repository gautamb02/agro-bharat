import 'package:agro_bharat/components/custom_text_field.dart';
import 'package:agro_bharat/config/constants.dart';
import 'package:agro_bharat/services/firestoreservice.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agro_bharat/screens/phone_number.dart';
import 'package:intl/intl.dart';

class FarmerProfile extends StatefulWidget {
  const FarmerProfile({Key? key}) : super(key: key);

  @override
  State<FarmerProfile> createState() => _FarmerProfileState();
}

class _FarmerProfileState extends State<FarmerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isEditing = false;
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  DateTime? _dob;

  // Custom colors
  static const Color primaryGreen = AppConstants.primaryGreen;
  static const Color secondaryGreen = AppConstants.primaryGreen;
  static const Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _user = _auth.currentUser;
    if (_user != null) {
      _userData = await _firestoreService.getUserById(_user!.uid);
      if (_userData != null) {
        setState(() {
          _nameController.text = _userData!['name'] ?? '';
          _addressController.text = _userData!['address'] ?? '';
          _stateController.text = _userData!['state'] ?? '';
          _pincodeController.text = _userData!['pincode'] ?? '';
          _dob = _userData!['dob'] != null ? DateTime.parse(_userData!['dob']) : null;
        });
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate() && _user != null) {
      try {
        await _firestoreService.updateUser(_user!.uid, {
          'name': _nameController.text,
          'address': _addressController.text,
          'state': _stateController.text,
          'pincode': _pincodeController.text,
          'dob': _dob?.toIso8601String(),
        });
        setState(() {
          _isEditing = false;
          _loadUserData();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully',style: TextStyle(color: Colors.black)), backgroundColor: AppConstants.cardBackgroundColor, behavior: SnackBarBehavior.floating,),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: AppConstants.primaryRed),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => PhoneNumberScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryGreen))),
      );
    }

    if (_user == null || _userData == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No user data available.', style: TextStyle(fontSize: 18, color: Colors.grey[800])),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Go to Login'),
                style: ElevatedButton.styleFrom(primary: primaryGreen),
                onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => PhoneNumberScreen())),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Farmer Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: () {
              if (_isEditing) {
                _updateUserData();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Name',
                      icon: Icons.person,
                      isEnabled: _isEditing,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.home,
                      isEnabled: _isEditing,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      icon: Icons.location_city,
                      isEnabled: _isEditing,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _pincodeController,
                      label: 'Pincode',
                      icon: Icons.pin_drop,
                      isEnabled: _isEditing,
                    ),
                    SizedBox(height: 20),
                    _buildDatePicker(context),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: _logout,

                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryRed,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child:
                            Text(
                              "Log Out",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'MuktaLatin',
                                fontSize: 19,
                              ),
                            ),

                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: _isEditing ? () => _selectDate(context) : null,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon: Icon(Icons.calendar_today, color: primaryGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryGreen, width: 2),
            ),
            enabled: _isEditing,
          ),
          controller: TextEditingController(
            text: _dob != null ? DateFormat('yyyy-MM-dd').format(_dob!) : '',
          ),
          style: TextStyle(fontSize: 16),
          validator: (value) => value!.isEmpty ? 'Please select your date of birth' : null,
        ),
      ),
    );
  }
}
