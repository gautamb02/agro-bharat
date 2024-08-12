import 'package:agro_bharat/screens/homescreen.dart';
import 'package:agro_bharat/services/firestoreservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agro_bharat/config/constants.dart';

class SignUpScreen extends StatefulWidget {
  final String phoneNumber;
  final String userId;
  const SignUpScreen(
      {Key? key, required this.phoneNumber, required this.userId})
      : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  FirestoreService _firestoreService = FirestoreService();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  String? _selectedState;
  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ];

  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleRegistration() async {
    final now = DateTime.now();
    final eighteenYearsAgo = now.subtract(const Duration(days: 18 * 365));

    if (_selectedDate == null || _selectedDate!.isAfter(eighteenYearsAgo)) {
      _showErrorSnackBar('You must be at least 18 years old to register.');
      return;
    }

    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _selectedState == null) {
      _showErrorSnackBar('Please fill in all the required fields.');
      return;
    }

    // Perform the registration logic here
    await _firestoreService.addUser(
        widget.phoneNumber,
        widget.userId,
        _nameController.text.trim(),
        _selectedDate.toString(),
        _addressController.text.trim(),
        _selectedState ?? "",
        _pincodeController.text.trim());

    Navigator.pop(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Add Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  cursorColor: Colors.black,
                  style: TextStyle(
                      fontFamily: 'Inter', height: 1, fontSize: 19),
                  decoration: InputDecoration(
                    iconColor: Colors.black,
                    hintText: 'Full Name',
                    filled: true,
                    fillColor: AppConstants.cardBackgroundColor,
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppConstants.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 16),
                        Text(
                          _selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                              : 'Date of Birth',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _addressController,
                  cursorColor: Colors.black,
                  style: TextStyle(
                      fontFamily: 'Inter', height: 1, fontSize: 19),
                  decoration: InputDecoration(
                    iconColor: Colors.black,
                    hintText: 'Address',
                    filled: true,
                    fillColor: AppConstants.cardBackgroundColor,
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  },
                  decoration: InputDecoration(
                    iconColor: Colors.black,
                    hintText: 'Select State',
                    filled: true,
                    fillColor: AppConstants.cardBackgroundColor,
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _states.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.black,
                  style: TextStyle(
                      fontFamily: 'Inter', height: 1, fontSize: 19),
                  decoration: InputDecoration(
                    iconColor: Colors.black,
                    hintText: 'Pincode',
                    filled: true,
                    fillColor: AppConstants.cardBackgroundColor,
                    prefixIcon: Icon(Icons.pin_drop),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _handleRegistration,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppConstants.primaryGreen),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(10)),
                    textStyle: MaterialStateProperty.all(const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontFamily: 'Inter',
                    )),
                  ),
                  child: const Text(
                    'Register',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
