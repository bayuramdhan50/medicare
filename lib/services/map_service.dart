import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  // Function to show a marker on the map
  Marker getMarker(LatLng position, String title) {
    return Marker(
      markerId: MarkerId(title),
      position: position,
      infoWindow: InfoWindow(title: title),
    );
  }

  // Example function to create a map with a hospital's location
  Set<Marker> createMarkers() {
    return {
      getMarker(LatLng(37.7749, -122.4194), "Hospital A"),
      getMarker(LatLng(34.0522, -118.2437), "Hospital B"),
    };
  }
}
