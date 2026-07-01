import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? '',
      'phone': prefs.getString('phone') ?? '',
      'bloodType': prefs.getString('bloodType') ?? 'O',
    };
  }

  static Future<void> saveProfile(String name, String phone, String bloodType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('phone', phone);
    await prefs.setString('bloodType', bloodType);
  }
}