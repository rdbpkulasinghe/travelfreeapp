import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as location;
import 'package:travelfreeapp/admin/location_picked.dart';
import 'package:travelfreeapp/admin/place_location.dart';

class EmergencyService extends StatefulWidget {
  const EmergencyService({Key? key}) : super(key: key);

  @override
  State<EmergencyService> createState() => _EmergencyServiceState();
}

class _EmergencyServiceState extends State<EmergencyService> {
  PlaceLocation? _pickedLocation;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  void _savePlace(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyBBDYXPXdmxcOPHh5PxeACQPNKNA6kLKKo');
    final response = await http.get(url);
    final resData = jsonDecode(response.body);
    final results = resData['results'];
    if (results != null && results.isNotEmpty) {
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      final Placemark place = placemarks[0];
      final fullAddress =
          '${place.street!}, ${place.locality!}, ${place.country!}';

      setState(() {
        _pickedLocation = PlaceLocation(
          latitude: latitude,
          longitude: longitude,
          address: fullAddress,
        );
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Selected Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: $fullAddress'),
              Text('Latitude: $_pickedLocation.latitude'),
              Text('Longitude: $_pickedLocation.longitude'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      _showNearbyPlaces(latitude, longitude);
    }
  }

  Future<void> _getCurrentLocation() async {
    location.Location locationData = location.Location();

    bool serviceEnabled;
    location.PermissionStatus permissionGranted;
    location.LocationData? locationResult;

    serviceEnabled = await locationData.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationData.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await locationData.hasPermission();
    if (permissionGranted == location.PermissionStatus.denied) {
      permissionGranted = await locationData.requestPermission();
      if (permissionGranted != location.PermissionStatus.granted) {
        return;
      }
    }

    try {
      locationResult = await locationData.getLocation();
    } catch (error) {
      print('Error getting location: $error');
    }

    if (locationResult == null) {
      return;
    }

    final lat = locationResult.latitude;
    final lng = locationResult.longitude;

    if (lat == null || lng == null) {
      return;
    }
    _savePlace(lat, lng);
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapSelect(),
      ),
    );
    if (pickedLocation == null) {
      return;
    }
    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  Future<void> _showNearbyPlaces(double latitude, double longitude) async {
    const apiKey = 'AIzaSyBBDYXPXdmxcOPHh5PxeACQPNKNA6kLKKo';
    const radius = 5000;
    const types = 'hospital|gas_station|lodging|police|atm';

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&types=$types&key=$apiKey');

    final response = await http.get(url);
    final responseData = jsonDecode(response.body);
    final results = responseData['results'];

    if (results != null && results.isNotEmpty) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('picked-location'),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(
              title: 'Picked Location',
              snippet: 'Your selected location',
            ),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );

        results.forEach((place) {
          final name = place['name'];
          final vicinity = place['vicinity'];
          final placeLatLng = LatLng(
            place['geometry']['location']['lat'],
            place['geometry']['location']['lng'],
          );
          _markers.add(
            Marker(
              markerId: MarkerId(placeLatLng.toString()),
              position: placeLatLng,
              infoWindow: InfoWindow(
                title: name,
                snippet: vicinity,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            ),
          );
        });
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(latitude, longitude),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Nearby Places'),
          content: const Text('No nearby places found.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Service'),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text('Get Current Location'),
                  onPressed: _getCurrentLocation,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Select on map'),
                  onPressed: _selectOnMap,
                ),
              ],
            ),
            Expanded(
              child: GoogleMap(
                markers: _markers,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
