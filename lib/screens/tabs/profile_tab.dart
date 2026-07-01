import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _bloodType = 'O';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await LocalStorageService.loadProfile();
    setState(() {
      _nameController.text = data['name']!;
      _phoneController.text = data['phone']!;
      _bloodType = data['bloodType']!;
    });
  }

  Future<void> _saveData() async {
    await LocalStorageService.saveProfile(_nameController.text, _phoneController.text, _bloodType);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil Darurat Tersimpan Lokal! ✅'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety, size: 60, color: Colors.blueGrey),
          const SizedBox(height: 16),
          const Text("Profil Darurat (Offline)", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Data ini disimpan aman di memori HP Anda.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
          const SizedBox(height: 16),
          TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor Darurat', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone))),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            // UPDATE FLUTTER TERBARU: Menggunakan initialValue alih-alih value
            initialValue: _bloodType,
            decoration: const InputDecoration(labelText: 'Golongan Darah', border: OutlineInputBorder(), prefixIcon: Icon(Icons.bloodtype)),
            items: ['A', 'B', 'AB', 'O'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
            onChanged: (val) => setState(() => _bloodType = val!),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[900], foregroundColor: Colors.white),
              child: const Text("SIMPAN DATA", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}