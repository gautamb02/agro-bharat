import 'package:agro_bharat/config/constants.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(

          height: 90,
          decoration: BoxDecoration(
            color: AppConstants.primaryGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.location_on, 'Locate Cow', 1),
              SizedBox(width: 60), // Space for FAB
              _buildNavItem(Icons.settings, 'Settings', 3),
              _buildNavItem(Icons.account_circle_sharp, 'Profile', 4),
            ],
          ),
        ),
        Positioned(
          top: -30,
          child: Column(
            children: [
              Container(
                height: 70.0,
                width: 70.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppConstants.primaryGreen,
                    width: 4.0,
                  ),
                ),
                child: FloatingActionButton(
                  elevation: 4,
                  shape: CircleBorder(),
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: AppConstants.primaryGreen, size: 30),
                  onPressed: () => onItemTapped(2),
                ),
              ),
              SizedBox(height: 8), // Add some space between FAB and text
              Text(
                'Add Cow',
                style: TextStyle(
                  color:  selectedIndex==2 ? Colors.white : Colors.white.withOpacity(0.7),

                  fontSize: 12,
                  fontWeight:  selectedIndex==2 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (selectedIndex == 2)
                Container(
                  width: 30,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 2),
          if (isSelected)
            Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}