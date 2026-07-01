import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const PadangShelterApp());
}

class PadangShelterApp extends StatelessWidget {
  const PadangShelterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Padang Shelter Offline',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}