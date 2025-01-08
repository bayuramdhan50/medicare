import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FindHospital extends StatefulWidget {
  @override
  _FindHospitalState createState() => _FindHospitalState();
}

class _FindHospitalState extends State<FindHospital> {
  late final MapController _mapController;
  double _zoom = 13.0;
  LatLng _center = LatLng(-6.9175, 107.6191); // Bandung
  String? _selectedHospital;

  // Daftar rumah sakit dengan koordinat
  final List<Map<String, dynamic>> _hospitals = [
    {"name": "RS Hasan Sadikin", "location": LatLng(-6.9572, 107.6256)},
    {"name": "RSUP Dr. Kariadi", "location": LatLng(-6.9274, 107.5971)},
    {"name": "RS Al Islam", "location": LatLng(-6.9237, 107.6253)},
    {"name": "RS Santo Yusuf", "location": LatLng(-6.9261, 107.6072)},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _selectHospital(String hospitalName, LatLng location) {
    setState(() {
      _selectedHospital = hospitalName;
      _center = location;
      _mapController.move(location, _zoom); // Pindahkan ke lokasi rumah sakit
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Find Hospital")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              maxZoom: 18.0,
              minZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _hospitals.map((hospital) {
                  return Marker(
                    point: hospital['location'],
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _selectHospital(
                          hospital['name'], hospital['location']),
                      child: Icon(Icons.local_hospital,
                          color: Colors.red, size: 35),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _zoom = (_zoom + 1).clamp(5.0, 18.0);
                      _mapController.move(_center, _zoom);
                    });
                  },
                  child: Icon(Icons.zoom_in),
                  backgroundColor: Colors.white,
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _zoom = (_zoom - 1).clamp(5.0, 18.0);
                      _mapController.move(_center, _zoom);
                    });
                  },
                  child: Icon(Icons.zoom_out),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          if (_selectedHospital != null)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Selected: $_selectedHospital",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: () {
                        // Tambahkan fungsi untuk lanjut ke halaman selanjutnya
                        print("Hospital $_selectedHospital selected!");
                      },
                      child: Text("Confirm"),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
