import 'package:agro_bharat/provider/cow_locations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:agro_bharat/config/constants.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final response = await http.get(
          Uri.parse('${AppConstants.COW_SENSOR_BASE_URL}/getDashboardOverview/${user.uid}'),
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          setState(() {
            _dashboardData = data;
            _isLoading = false;
          });

          List<CowLocation> cowLocations = [];
          for (var reading in data['latestReadings']) {
            if (reading['gps'] != null && reading['gps']['latitude'] != null && reading['gps']['longitude'] != null) {
              cowLocations.add(CowLocation(
                cowId: reading['cowId'],
                latitude: reading['gps']['latitude'],
                longitude: reading['gps']['longitude'],
              ));
            }
          }
          Provider.of<CowLocationProvider>(context, listen: false).updateCowLocations(cowLocations);

        } else {
          throw Exception('Failed to load dashboard data');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.error_message}  ${e.toString()}")),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.user_not_logged_in)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppConstants.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(15))),
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.home_tab, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.latest_readings,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildLatestReadings(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildCard(AppLocalizations.of(context)!.total_cows, _dashboardData['totalCows']?.toString() ?? 'N/A', Icons.pets),
        _buildCard(AppLocalizations.of(context)!.total_records, _dashboardData['totalRecords']?.toString() ?? 'N/A', Icons.assessment),
        _buildCard(AppLocalizations.of(context)!.avg_temperature, _formatValue(_dashboardData['averageTemperature'], '°C'), Icons.thermostat),
        _buildCard(AppLocalizations.of(context)!.avg_heart_rate, _formatValue(_dashboardData['averageHeartRate'], ' BPM', 0), Icons.favorite),
      ],
    );
  }

  String _formatValue(dynamic value, String unit, [int decimalPlaces = 1]) {
    if (value == null) return 'N/A';
    if (value is num) {
      return '${value.toStringAsFixed(decimalPlaces)}$unit';
    }
    return '$value$unit';
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return Card(
      color: AppConstants.cardBackgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppConstants.primaryBlue),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestReadings() {
    List<dynamic> latestReadings = _dashboardData['latestReadings'] ?? [];
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: latestReadings.length,
      itemBuilder: (context, index) {
        var reading = latestReadings[index];
        return Card(
          elevation: 1,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text('Cow ID: ${reading['cowId'] ?? 'N/A'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Temperature: ${_formatValue(reading['tmp117']?['temperature'], '°C')}'),
                Text('Heart Rate: ${_formatValue(reading['max30100']?['heart_rate'], ' BPM', 0)}'),
                Text('SPO2: ${_formatValue(reading['max30100']?['spo2'], '%', 0)}'),
                Text('GPS: Lat ${_formatValue(reading['gps']?['latitude'], '°', 6)}, '
                    'Long ${_formatValue(reading['gps']?['longitude'], '°', 6)}'),
              ],
            ),
            trailing: Text(
              _formatTimestamp(reading['timestamp']),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }


  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Map<String, dynamic> &&
        timestamp.containsKey('seconds') &&
        timestamp.containsKey('nanoseconds')) {
      int milliseconds = timestamp['seconds'] * 1000 + (timestamp['nanoseconds'] / 1000000).round();
      return DateTime.fromMillisecondsSinceEpoch(milliseconds).toString().split('.')[0];
    }
    return 'Invalid timestamp';
  }
}
