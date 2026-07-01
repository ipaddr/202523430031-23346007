import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'tabs/map_tab.dart'; 
import 'tabs/profile_tab.dart';
import '../services/ble_service.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isSosActive = false;
  bool _isProcessing = false; // Mencegah user menekan tombol berulang kali
  
  // Menyimpan koordinat korban sungguhan dari udara
  List<LatLng> _detectedVictims = []; 

  @override
  void initState() {
    super.initState();
  }

  // FUNGSI RADAR REAL-TIME (PENCARI)
  Future<void> _scanForVictims() async {
    setState(() => _isProcessing = true); 

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memindai gelombang BLE di sekitar... 📡'), backgroundColor: Colors.blue, duration: Duration(seconds: 4))
      );
    }

    // Panggil mesin pemindai sungguhan untuk mendengarkan sinyal di udara
    List<LatLng> realVictims = await BleService.scanForVictims();

    if (mounted) {
      setState(() {
        _detectedVictims = realVictims; // Lempar hasil nyata ke Peta
        _selectedIndex = 0; // AUTO-REDIRECT: Pindah layar otomatis ke Peta
      });
      
      if (realVictims.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${realVictims.length} Korban Terdeteksi! Lihat Peta.'), backgroundColor: Colors.orange)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada sinyal darurat di sekitar.'), backgroundColor: Colors.blueGrey)
        );
      }
      setState(() => _isProcessing = false);
    }
  }

  // FUNGSI PEMANCAR SOS REAL-TIME (BERBASIS GPS)
  void _toggleSos() async {
    if (_isProcessing) return; 
    setState(() => _isProcessing = true);

    try {
      // --- JIKA INGIN MENYALAKAN SOS ---
      if (!_isSosActive) {
        
        // 1. Minta Semua Izin
        Map<Permission, PermissionStatus> statuses = await [
          Permission.location, 
          Permission.bluetooth, 
          Permission.bluetoothScan, 
          Permission.bluetoothAdvertise, 
          Permission.bluetoothConnect,
        ].request();

        bool isAdvertiseGranted = statuses[Permission.bluetoothAdvertise]?.isGranted ?? false;
        if (!isAdvertiseGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal: Izin Bluetooth harus diberikan!'), backgroundColor: Colors.orange)
            );
          }
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mengambil koordinat satelit GPS...'), backgroundColor: Colors.blueGrey, duration: Duration(seconds: 2))
          );
        }

        // 2. AMBIL TITIK GPS ASLI ANDA
        Position pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
        );

        // 3. JEDA NAPAS ANTI-CRASH (1.5 Detik untuk menstabilkan hardware Android)
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // 4. PANCARKAN GELOMBANG RADIO BERSAMA KOORDINAT ANDA
        await BleService.startBroadcast(pos.latitude, pos.longitude);
        setState(() => _isSosActive = true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sinyal Darurat & Lokasi GPS Dipancarkan! 📡'), backgroundColor: Colors.red, duration: Duration(seconds: 3))
          );
        }
        
      } 
      // --- JIKA INGIN MEMATIKAN SOS ---
      else {
        await BleService.stopBroadcast();
        setState(() => _isSosActive = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sinyal Darurat Dihentikan.'), backgroundColor: Colors.blueGrey)
          );
        }
      }
    } catch (e) {
      debugPrint("Terjadi kesalahan sistem saat toggle SOS: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  @override
  void dispose() {
    BleService.stopBroadcast(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Padang Shelter Offline' : _selectedIndex == 1 ? 'Radar Sinyal BLE' : 'Profil Darurat', 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        backgroundColor: _isSosActive && _selectedIndex == 0 ? Colors.red[700] : Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // INDEX 0: LAYAR PETA
          MapTab(isSosActive: _isSosActive, onToggleSos: _toggleSos, detectedVictims: _detectedVictims),
          
          // INDEX 1: LAYAR RADAR
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.radar, 
                  size: 120, 
                  color: _isProcessing ? Colors.amber : Colors.blueGrey[300]
                ),
                const SizedBox(height: 24),
                const Text("Pemindai Sinyal Korban", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  child: Text(
                    "Pindai area sekitar menggunakan gelombang Bluetooth Low Energy untuk mencari sinyal SOS beserta koordinat GPS dari korban lain.", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.grey, fontSize: 14)
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _scanForVictims,
                    icon: _isProcessing 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Icon(Icons.search, size: 28),
                    label: Text(
                      _isProcessing ? "MEMINDAI AREA..." : "MULAI PEMINDAIAN", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                  ),
                )
              ],
            ),
          ),
          
          // INDEX 2: LAYAR PROFIL
          const ProfileTab(),
        ],
      ),
                
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueGrey[900],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Peta'),
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Radar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}