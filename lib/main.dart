import 'package:flutter/material.dart';
import 'screens/hospital_list_screen.dart';

// Renk paleti
const Color kBackgroundColor = Color(0xFFF5EFE6); // en açık
const Color kPrimaryColor = Color(0xFFCBDCEB); // orta
const Color kAccentColor = Color(0xFFB6C2D4); // daha koyu, palete uygun
const Color kButtonColor = Color(0xFFCBDCEB); // ana buton
const Color kAddButtonColor = Color(0xFFB6C2D4); // ekle butonu
const Color kTextColor = Color(0xFF333333);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hastane Device',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HospitalListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
