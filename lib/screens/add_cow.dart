import 'package:flutter/material.dart';

class AddCow extends StatefulWidget {
  const AddCow({Key? key}) : super(key: key);

  @override
  State<AddCow> createState() => _AddCowState();
}

class _AddCowState extends State<AddCow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Add Cow"),),
    );
  }
}
