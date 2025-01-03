import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/widgets/custom_button.dart';

class FindHospitalScreen extends StatefulWidget {
  final UserModel user;

  FindHospitalScreen({required this.user});

  @override
  _FindHospitalScreenState createState() => _FindHospitalScreenState();
}

class _FindHospitalScreenState extends State<FindHospitalScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};

  // Initial position of the map (can be your current location or a default position)
  static const LatLng _initialPosition =
      LatLng(37.7749, -122.4194); // San Francisco

  @override
  void initState() {
    super.initState();
    _addHospitalMarkers();
  }

  // Method to add markers for hospitals
  void _addHospitalMarkers() {
    // Example list of hospitals, you can replace this with actual data
    List<LatLng> hospitalLocations = [
      LatLng(37.7749, -122.4194), // Example hospital location 1 (San Francisco)
      LatLng(37.7849, -122.4294), // Example hospital location 2
      LatLng(37.7949, -122.4394), // Example hospital location 3
    ];

    setState(() {
      _markers.clear();
      for (var location in hospitalLocations) {
        _markers.add(Marker(
          markerId: MarkerId(location.toString()),
          position: location,
          infoWindow: InfoWindow(title: 'Hospital', snippet: 'Address'),
        ));
      }
    });
  }

  // Method to move the camera to a specific position
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Hospital'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          // Google Map to display hospital locations
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              markers: _markers,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: 'Search Hospitals Nearby', // Button to search hospitals
              onPressed: () {
                // You can implement API or logic to search hospitals here
                // For now, it just reloads the markers
                _addHospitalMarkers();
              },
            ),
          ),
        ],
      ),
    );
  }
}
