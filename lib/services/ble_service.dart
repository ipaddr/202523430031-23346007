import 'package:flutter/foundation.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:latlong2/latlong.dart';

class BleService {
  static final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
  // ID unik produsen buatan kita untuk memfilter aplikasi Padang Shelter
  static const int _companyId = 0xFFFF; 

  // Mengubah Latitude & Longitude (Double) menjadi 8-Byte Array
  static Uint8List _encodeLocation(double lat, double lng) {
    final ByteData data = ByteData(8);
    data.setFloat32(0, lat, Endian.little);
    data.setFloat32(4, lng, Endian.little);
    return data.buffer.asUint8List();
  }

  // Membongkar 8-Byte Array kembali menjadi koordinat Peta
  static LatLng? _decodeLocation(List<int> bytes) {
    if (bytes.length < 8) return null; 
    final ByteData data = ByteData.sublistView(Uint8List.fromList(bytes));
    double lat = data.getFloat32(0, Endian.little);
    double lng = data.getFloat32(4, Endian.little);
    return LatLng(lat, lng);
  }

  // PEMANCAR (HP KORBAN)
  static Future<void> startBroadcast(double lat, double lng) async {
    try {
      bool isSupported = await _blePeripheral.isSupported;
      if (!isSupported) return;

      // Hentikan pemancaran lama terlebih dahulu untuk membersihkan sisa set data
      if (await _blePeripheral.isAdvertising) {
        await _blePeripheral.stop();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // PAKET DATA MINIMALIS (Bebas Crash 31-Byte Limit)
      final advertiseData = AdvertiseData(
        manufacturerId: _companyId, 
        manufacturerData: _encodeLocation(lat, lng), // Koordinat disisipkan di sini
      );

      await _blePeripheral.start(advertiseData: advertiseData);
      debugPrint("BLE Memancar dengan Payload GPS: $lat, $lng");
    } catch (e) {
      debugPrint("Gagal memancar BLE: $e");
    }
  }

  static Future<void> stopBroadcast() async {
    try {
      if (await _blePeripheral.isAdvertising) {
        await _blePeripheral.stop();
      }
    } catch (e) {
      debugPrint("Gagal menghentikan BLE: $e");
    }
  }

  // PEMINDAI RADAR REAL-TIME (HP PENCARI)
  static Future<List<LatLng>> scanForVictims() async {
    List<LatLng> victims = [];
    try {
      // Pastikan Bluetooth aktif
      if (await fbp.FlutterBluePlus.adapterState.first == fbp.BluetoothAdapterState.off) {
        return victims;
      }

      // Pemindaian terbuka (Mencari semua perangkat BLE di sekitar selama 4 detik)
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
      );

      // Membaca setiap sinyal radio yang tertangkap di udara
      final scanResults = await fbp.FlutterBluePlus.scanResults.first;
      
      for (fbp.ScanResult r in scanResults) {
        // FILTER: Apakah paket memiliki ID Khusus Aplikasi Kita (0xFFFF)?
        if (r.advertisementData.manufacturerData.containsKey(_companyId)) {
          List<int> payload = r.advertisementData.manufacturerData[_companyId]!;
          LatLng? victimLoc = _decodeLocation(payload);
          
          // Validasi koordinat dan cegah duplikasi data di dalam list
          if (victimLoc != null) {
            bool isAlreadyAdded = victims.any((v) => 
              v.latitude == victimLoc.latitude && v.longitude == victimLoc.longitude
            );
            
            if (!isAlreadyAdded) {
              victims.add(victimLoc);
              debugPrint("Korban Terdeteksi di: ${victimLoc.latitude}, ${victimLoc.longitude}");
            }
          }
        }
      }

      await fbp.FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint("Gagal memindai: $e");
    }
    return victims;
  }
}