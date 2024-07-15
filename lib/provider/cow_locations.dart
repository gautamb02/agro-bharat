import 'package:flutter/foundation.dart';

class CowLocation {
  final String cowId;
  final double latitude;
  final double longitude;

  CowLocation({required this.cowId, required this.latitude, required this.longitude});
}

class CowLocationProvider with ChangeNotifier {
  List<CowLocation> _cowLocations = [];

  List<CowLocation> get cowLocations => _cowLocations;

  void updateCowLocations(List<CowLocation> newLocations) {
    _cowLocations = newLocations;
    notifyListeners();
  }
}