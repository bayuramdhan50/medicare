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

  final List<Map<String, dynamic>> _hospitals = [
    {
      "name": "RS Hasan Sadikin",
      "location": LatLng(-6.9572, 107.6256),
      "address": "Jl. Pasteur No. 38, Bandung",
      "phone": "(022) 2034953",
      "rating": 4.5
    },
    {
      "name": "RSUP Dr. Kariadi",
      "location": LatLng(-6.9274, 107.5971),
      "address": "Jl. Dr. Sutomo No. 16, Bandung",
      "phone": "(022) 2034888",
      "rating": 4.3
    },
    {
      "name": "RS Al Islam",
      "location": LatLng(-6.9237, 107.6253),
      "address": "Jl. Soekarno Hatta No. 644, Bandung",
      "phone": "(022) 7565656",
      "rating": 4.4
    },
    {
      "name": "RS Santo Yusuf",
      "location": LatLng(-6.9261, 107.6072),
      "address": "Jl. Cikutra No. 7, Bandung",
      "phone": "(022) 7208172",
      "rating": 4.2
    },
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
      _mapController.move(location, _zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
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
                  bool isSelected = hospital['name'] == _selectedHospital;
                  return Marker(
                    point: hospital['location'],
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _selectHospital(
                          hospital['name'], hospital['location']),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          Icons.local_hospital,
                          color: isSelected ? Colors.blue : Colors.red,
                          size: isSelected ? 40 : 35,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.blue),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search hospitals...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Zoom Controls
          Positioned(
            right: 16,
            bottom: _selectedHospital != null ? 220 : 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        _zoom = (_zoom + 1).clamp(5.0, 18.0);
                        _mapController.move(_center, _zoom);
                      });
                    },
                  ),
                  Container(
                    height: 1,
                    width: 20,
                    color: Colors.grey[300],
                  ),
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        _zoom = (_zoom - 1).clamp(5.0, 18.0);
                        _mapController.move(_center, _zoom);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Hospital Info Card
          if (_selectedHospital != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_hospital, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedHospital!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.location_on,
                            _hospitals.firstWhere((h) =>
                                h['name'] == _selectedHospital)['address'],
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.phone,
                            _hospitals.firstWhere(
                                (h) => h['name'] == _selectedHospital)['phone'],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                _hospitals
                                    .firstWhere((h) =>
                                        h['name'] ==
                                        _selectedHospital)['rating']
                                    .toString(),
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Add navigation functionality
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Get Directions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
