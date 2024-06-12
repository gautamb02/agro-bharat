import 'package:agro_bharat/config/constants.dart';
import 'package:flutter/material.dart';

class LanguageButton extends StatelessWidget {
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;
  final double widthPercentage;

  const LanguageButton({
    required this.languageName,
    required this.isSelected,
    required this.onTap,
    this.widthPercentage = 0.6, // Default value is 50% of the screen width
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth * widthPercentage;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: buttonWidth, // Set the width based on the calculated value
            alignment: AlignmentDirectional.center,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              languageName,
              style: TextStyle(
                fontFamily: 'MuktaLatin',
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15
              ),
            ),
          ),
        );
      },
    );
  }
}