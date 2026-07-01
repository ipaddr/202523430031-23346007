import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/shelter_data.dart';

class MapTab extends StatefulWidget {
  final bool isSosActive;
  final VoidCallback onToggleSos;
  final List<LatLng> detectedVictims; 

  const MapTab({
    super.key, 
    required this.isSosActive, 
    required this.onToggleSos,
    required this.detectedVictims, 
  });

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  late MbTiles _mbtiles;
  bool _isMapReady = false;
  String _errorMessage = '';
  final MapController _mapController = MapController();
  
  LatLng? _userLocation;
  Map<String, dynamic>? _nearestShelter;
  double _distanceToNearest = 0;
  int _estimatedTime = 0;

  @override
  void initState() {
    super.initState();
    _initOfflineMap();
    _fetchUserLocation(); // Selalu cari lokasi kita saat peta dibuka agar bisa hitung jarak
  }

  @override
  void didUpdateWidget(MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika SOS baru ditekan, pastikan lokasi terupdate
    if (widget.isSosActive && !oldWidget.isSosActive) {
      _fetchUserLocation();
    }
  }

  Future<void> _initOfflineMap() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/Padang.mbtiles';
      final file = File(path);

      if (!await file.exists()) {
        final byteData = await rootBundle.load('assets/maps/Padang.mbtiles');
        await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      }

      _mbtiles = MbTiles(mbtilesPath: path);
      setState(() => _isMapReady = true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _fetchUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
    );
    LatLng userLatLng = LatLng(position.latitude, position.longitude);
    
    final Distance distanceCalc = const Distance();
    double minDistance = double.infinity;
    Map<String, dynamic>? nearest;

    for (var shelter in ShelterData.locations) {
      double dist = distanceCalc.as(LengthUnit.Meter, userLatLng, shelter['location']);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = shelter;
      }
    }

    if (mounted) {
      setState(() {
        _userLocation = userLatLng;
        _nearestShelter = nearest;
        _distanceToNearest = minDistance;
        _estimatedTime = (minDistance / 80).ceil(); 
      });
      _mapController.move(userLatLng, 14.5);
    }
  }

  @override
  void dispose() {
    if (_isMapReady) _mbtiles.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) return Center(child: Text("Error: $_errorMessage"));
    if (!_isMapReady) return const Center(child: CircularProgressIndicator());

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(-0.9242, 100.3624),
            initialZoom: 14.0, maxZoom: 16.0, minZoom: 13.0,
          ),
          children: [
            TileLayer(tileProvider: MbTilesTileProvider(mbtiles: _mbtiles)),
            
            if (_userLocation != null && _nearestShelter != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_userLocation!, _nearestShelter!['location']], 
                    color: Colors.blueAccent.withValues(alpha: 0.8), 
                    strokeWidth: 5.0
                  ),
                ],
              ),
              
            MarkerLayer(
              markers: [
                // 1. MARKER SHELTER (Pin Merah)
                ...ShelterData.locations.map((s) => Marker(
                  point: s['location'], width: 60, height: 60, 
                  child: Tooltip(
                    message: s['name'], triggerMode: TooltipTriggerMode.tap, preferBelow: false,
                    decoration: BoxDecoration(color: Colors.blueGrey[900]?.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), showDuration: const Duration(seconds: 3),
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                )),

                // 2. MARKER KORBAN BLE (Titik Kuning + Kalkulasi Jarak Real-Time)
                ...widget.detectedVictims.map((korbanLatLng) {
                  // KALKULASI JARAK
                  String distanceText = "Jarak: Menunggu GPS...";
                  if (_userLocation != null) {
                    final dist = const Distance().as(LengthUnit.Meter, _userLocation!, korbanLatLng);
                    distanceText = "Jarak: ${dist.toInt()} meter"; // Angka dibulatkan
                  }

                  return Marker(
                    point: korbanLatLng, 
                    width: 40, // Area hitbox agar mudah di-tap
                    height: 40,
                    child: Tooltip(
                      message: "Sinyal SOS Darurat!\n$distanceText", 
                      triggerMode: TooltipTriggerMode.tap, preferBelow: false,
                      decoration: BoxDecoration(color: Colors.orange[900]?.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), showDuration: const Duration(seconds: 4),
                      // DESAIN TITIK KUNING
                      child: Center(
                        child: Container(
                          width: 20, 
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            border: Border.all(color: Colors.white, width: 2), 
                            color: Colors.amber
                          )
                        ),
                      ),
                    ),
                  );
                }),
                
                // 3. MARKER LOKASI USER (Titik Biru)
                if (_userLocation != null)
                  Marker(
                    point: _userLocation!, width: 20, height: 20, 
                    child: Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), color: Colors.blue)),
                  ),
              ],
            ),
          ],
        ),

        if (_nearestShelter != null)
          Positioned(
            bottom: 90, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
                border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.home_work, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(_nearestShelter!['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))]),
                  const Divider(height: 16),
                  Row(children: [
                    const Icon(Icons.straighten, size: 18, color: Colors.blueGrey), const SizedBox(width: 4), Text("Jarak: ${_distanceToNearest.toInt()} m", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.directions_walk, size: 18, color: Colors.blueGrey), const SizedBox(width: 4), Text("Estimasi: $_estimatedTime mnt", style: const TextStyle(fontWeight: FontWeight.w600)),
                  ])
                ],
              ),
            ),
          ),
          
        Positioned(
          bottom: 20, left: 0, right: 0,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85, height: 55,
              child: ElevatedButton.icon(
                onPressed: widget.onToggleSos, 
                icon: const Icon(Icons.sensors, size: 28),
                label: Text(widget.isSosActive ? "HENTIKAN SOS" : "PANCAR SOS (SIMULASI)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: widget.isSosActive ? Colors.red[800] : Colors.orange[800], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ),
        ),
      ],
    );
  }
}