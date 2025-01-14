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
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredHospitals = [];

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
    _filteredHospitals = _hospitals; // Inisialisasi dengan semua rumah sakit
  }

  void _searchHospitals(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHospitals = _hospitals;
      } else {
        _filteredHospitals = _hospitals.where((hospital) {
          final name = hospital['name'].toString().toLowerCase();
          final address = hospital['address'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || address.contains(searchLower);
        }).toList();

        // Jika ada hasil pencarian, tampilkan info rumah sakit pertama
        if (_filteredHospitals.isNotEmpty) {
          _selectHospital(
            _filteredHospitals[0]['name'],
            _filteredHospitals[0]['location'],
          );
        }
      }
    });
  }

  void _selectHospital(String hospitalName, LatLng location) {
    setState(() {
      _selectedHospital = hospitalName;
      _center = location;
      _mapController.move(location, _zoom);
    });
  }

  // Tambahkan widget untuk menampilkan hasil pencarian
  Widget _buildSearchResults() {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        constraints: BoxConstraints(maxHeight: 200),
        child: SingleChildScrollView(
          child: Column(
            children: _filteredHospitals.map((hospital) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.local_hospital, color: Color(0xFF1565C0)),
                  title: Text(
                    hospital['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  subtitle: Text(hospital['address']),
                  onTap: () {
                    _selectHospital(hospital['name'], hospital['location']);
                    _searchController.clear();
                    _searchHospitals('');
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Layer dengan gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF42A5F5).withOpacity(0.1),
                  Color(0xFF2196F3).withOpacity(0.3),
                ],
              ),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: _zoom,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _filteredHospitals.map((hospital) {
                    bool isSelected = hospital['name'] == _selectedHospital;
                    return Marker(
                      point: hospital['location'],
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _selectHospital(
                            hospital['name'], hospital['location']),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Color(0xFF2196F3).withOpacity(0.8)
                                        : Colors.white.withOpacity(0.7),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      )
                                    ]),
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.local_hospital,
                                  color: isSelected
                                      ? Colors.white
                                      : Color(0xFF2196F3),
                                  size: isSelected ? 30 : 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Search Header dengan desain modern
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
                    Color(0xFF42A5F5),
                    Color(0xFF2196F3),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchHospitals,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.search, color: Color(0xFF2196F3)),
                              hintText: 'Cari rumah sakit...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Hospital Info Card dengan desain modern
          if (_selectedHospital != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF42A5F5),
                      Color(0xFF2196F3),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedHospital!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildInfoRow(
                        Icons.location_on,
                        _hospitals.firstWhere(
                            (h) => h['name'] == _selectedHospital)['address'],
                        Colors.white,
                      ),
                      SizedBox(height: 10),
                      _buildInfoRow(
                        Icons.phone,
                        _hospitals.firstWhere(
                            (h) => h['name'] == _selectedHospital)['phone'],
                        Colors.white,
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          // Tambahkan fungsi navigasi
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF2196F3),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions),
                            SizedBox(width: 10),
                            Text(
                              'Petunjuk Arah',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Perbarui method _buildInfoRow untuk mendukung warna kustom
  Widget _buildInfoRow(IconData icon, String text, [Color? iconColor]) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Colors.grey, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: iconColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
