import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

class Location {
  String name;
  GeoPoint position;

  Location({required this.name, required this.position});
}

class LocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Geoflutterfire _geo = Geoflutterfire();

  // Get locations within a certain radius of a given point
  Future<List<Location>> getNearbyLocations(double latitude, double longitude,
      {double radius = 10.0}) async {
    GeoFirePoint center = _geo.point(latitude: latitude, longitude: longitude);
    Stream<List<DocumentSnapshot>> stream = _geo
        .collection(collectionRef: _db.collection('Pets'))
        .within(
            center: center,
            radius: radius,
            field: 'position',
            strictMode: true);

    List<Location> nearbyLocations = [];
    await stream.first.then((list) {
      list.forEach((doc) {
        Location location =
            Location(name: doc['name'], position: doc['position']);
        nearbyLocations.add(location);
      });
    });

    return nearbyLocations;
  }
}

class LocationListPage extends StatefulWidget {
  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  final LocationService _locationService = LocationService();
  double _latitude = 37.773972;
  double _longitude = -122.431297;
  double _radius = 10.0;
  List<Location> _nearbyLocations = [];

  @override
  void initState() {
    super.initState();
    _getNearbyLocations();
  }

  Future<void> _getNearbyLocations() async {
    List<Location> nearbyLocations = await _locationService
        .getNearbyLocations(_latitude, _longitude, radius: _radius);
    setState(() {
      _nearbyLocations = nearbyLocations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locations'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Latitude: $_latitude'),
            Text('Longitude: $_longitude'),
            SizedBox(height: 20),
            Slider(
              value: _radius,
              min: 1,
              max: 50,
              divisions: 9,
              label: '${_radius.toStringAsFixed(1)} km',
              onChanged: (double value) {
                setState(() {
                  _radius = value;
                });
              },
            ),
            ElevatedButton(
              child: Text('Refresh'),
              onPressed: _getNearbyLocations,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _nearbyLocations.length,
                itemBuilder: (BuildContext context, int index) {
                  Location location = _nearbyLocations[index];
                  return ListTile(
                    title: Text(location.name),
                    subtitle: Text(
                        'Latitude: ${location.position.latitude.toStringAsFixed(6)}, Longitude: ${location.position.longitude.toStringAsFixed(6)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
