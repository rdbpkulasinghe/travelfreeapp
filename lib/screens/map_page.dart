import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String placeName;
  final String address;

  const MapPage({
    required this.latitude,
    required this.longitude,
    required this.placeName,
    required this.address,
    Key? key,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late LatLng currentLocation;
  late LatLng destinationLocation;
  String? distance;
  String? duration;
  late TextEditingController _destinationController;
  late List<PointLatLng> _polylines = [];
  String _selectedTravelMode = 'walking'; // Default travel mode

  @override
  void initState() {
    super.initState();
    currentLocation = LatLng(widget.latitude, widget.longitude);
    destinationLocation =
        const LatLng(6.93194, 79.84778); // Default destination
    _destinationController = TextEditingController();
    _getDirections();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getDirections() async {
    // Make API request to Google Directions API with selected travel mode
    String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${destinationLocation.latitude},${destinationLocation.longitude}&mode=$_selectedTravelMode&key=AIzaSyBBDYXPXdmxcOPHh5PxeACQPNKNA6kLKKo';
    var response = await http.get(Uri.parse(apiUrl));
    var jsonData = jsonDecode(response.body);

    // Parse response
    List<LatLng> points = [];
    if (jsonData['routes'] != null && jsonData['routes'].isNotEmpty) {
      jsonData['routes'][0]['legs'][0]['steps'].forEach((step) {
        points.add(LatLng(
            step['start_location']['lat'], step['start_location']['lng']));
      });
      distance = jsonData['routes'][0]['legs'][0]['distance']['text'];
      duration = jsonData['routes'][0]['legs'][0]['duration']['text'];
      _polylines = PolylinePoints()
          .decodePolyline(jsonData['routes'][0]['overview_polyline']['points']);
    }

    // Add polyline between current location and destination
    points.insert(0, currentLocation);
    points.add(destinationLocation);

    // Update UI
    setState(() {
      destinationLocation =
          points.isNotEmpty ? points.last : destinationLocation;
    });
  }

  Future<void> _searchAndSetDestination(String query) async {
    List<Location> locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      setState(() {
        destinationLocation =
            LatLng(locations[0].latitude, locations[0].longitude);
      });
      _getDirections();
    } else {
      print('Place not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map: ${widget.placeName}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    (currentLocation.latitude + destinationLocation.latitude) /
                        2,
                    (currentLocation.longitude +
                            destinationLocation.longitude) /
                        2,
                  ),
                  zoom: 8.5, //zoom level
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: currentLocation,
                    infoWindow: const InfoWindow(
                      title: 'Current Location',
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('destinationLocation'),
                    position: destinationLocation,
                    infoWindow: InfoWindow(
                      title: widget.placeName,
                      snippet:
                          'Distance: ${distance ?? ''}, Duration: ${duration ?? ''}',
                    ),
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('12'),
                    color: Colors.red,
                    width: 5,
                    points: _polylines
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: _selectedTravelMode,
                    onChanged: (value) {
                      setState(() {
                        _selectedTravelMode = value!;
                      });
                      _getDirections();
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'driving',
                        child: Text('Driving'),
                      ),
                      DropdownMenuItem(
                        value: 'walking',
                        child: Text('Walking'),
                      ),
                      DropdownMenuItem(
                        value: 'transit',
                        child: Text('Transit'),
                      ),
                      /*DropdownMenuItem(
                        value: 'train',
                        child: Text('Train'),
                      ),*/
                    ],
                  ),
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      labelText: 'Enter destination',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _searchAndSetDestination(_destinationController.text);
                        },
                      ),
                    ),
                  ),
                  Text(
                    '\n Address: ${widget.address}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
