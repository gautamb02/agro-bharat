import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:agro_bharat/config/constants.dart';
import 'package:agro_bharat/loader/mapskeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocateCow extends StatefulWidget {
  const LocateCow({Key? key}) : super(key: key);

  @override
  State<LocateCow> createState() => _LocateCowState();
}

class _LocateCowState extends State<LocateCow> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _locationObtained = false;
  LatLng _currentPosition = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers = [
        Marker(
          point: _currentPosition,
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlueAccent.withOpacity(0.5),
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.circle,
                  size: 20,
                  color: Colors.blueAccent,
                ),
              ),
              Positioned(
                top: 30,
                child: Text(
                  'You',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];

      _generateRandomNearbyLocations();
      _locationObtained = true;
    });
  }

  void _generateRandomNearbyLocations() {
    final random = Random();
    const int numberOfLocations = 5;
    const double maxDistance = 0.001;

    for (int i = 0; i < numberOfLocations; i++) {
      double randomLat = _currentPosition.latitude + (random.nextDouble() - 0.5) * maxDistance;
      double randomLng = _currentPosition.longitude + (random.nextDouble() - 0.5) * maxDistance;
      LatLng randomPosition = LatLng(randomLat, randomLng);

      _markers.add(
        Marker(
          point: randomPosition,
          width: 60,
          height: 60,
          child: GestureDetector(
            onTap: () => _showDirectionsDialog(randomPosition),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_pin,
                  size: 30,
                  color: Colors.red,
                ),
                Positioned(
                  top: 40,
                  child: Text(
                    'Loc ${i + 1}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    setState(() {
      print("Markers updated: $_markers");
    });
  }

  void _showDirectionsDialog(LatLng destination) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Get Directions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Do you want to get directions to this location?',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openGoogleMaps(destination);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Yes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
        contentPadding: EdgeInsets.all(20),
        titlePadding: EdgeInsets.only(top: 20, left: 20, right: 20),
        actionsPadding: EdgeInsets.only(right: 10, bottom: 10),
      ),
    );
  }

  Future<void> _openGoogleMaps(LatLng destination) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${destination.latitude},${destination.longitude}',
      'travelmode': 'driving',
    });
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.locateCow_tab, style: TextStyle(fontFamily: 'Outfit',color: Colors.white,fontWeight: FontWeight.w700, fontSize: 25)),
        backgroundColor: AppConstants.primaryGreen,
        elevation: 0,
        centerTitle: true,
        // flexibleSpace: ClipRect(
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 10,sigmaY:10 ),
        //     child: Container(color: Colors.transparent),
        //   ),
        // ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.zero,bottom: Radius.circular(15))),
      ),
      body: _locationObtained ? content() : const MapSkeletonLoader(),
    );
  }

  Widget content() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: 18,
            interactionOptions: const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
          ),
          children: [
            openStreetMapTileLayer,
            MarkerLayer(markers: _markers),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            shape: CircleBorder(),
            child: Icon(Icons.my_location, color: Colors.black),
            onPressed: () {
              _mapController.move(_currentPosition, 18);
            },
          ),
        ),
      ],
    );
  }
}


TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'labs.aim.agro_bharat',
  tileBuilder: _tileUIBuilder,
);


Widget _tileUIBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
    ) {
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0,      0,      0,      1, 0,
    ]),
    child: tileWidget,
  );
}

Widget _darkMode(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
    ) {
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0,      0,      0,      1, 0,
    ]),
    child: tileWidget,
  );
}

