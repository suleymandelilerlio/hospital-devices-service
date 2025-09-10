import 'package:flutter/material.dart';
import '../core/database_helper.dart';
import '../models/hospital.dart';
import '../screens/device_list_screen.dart';

// Renk paleti
const Color kBackgroundColor = Color(0xFFF5EFE6); // en açık
const Color kPrimaryColor = Color(0xFF6D94C5); // orta

const Color kAccentColor = Color(0xFF6D94C5); // daha koyu, palete uygun
const Color kButtonColor = Color(0xFFCBDCEB); // ana buton
const Color kAddButtonColor = Color(0xFFB6C2D4); // ekle butonu
const Color kTextColor = Colors.white;


class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({Key? key}) : super(key: key);

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  List<Hospital> hospitals = [];

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    final db = await DatabaseHelper().db;
    final result = await db.query('hospitals');
    setState(() {
      hospitals = result.map((e) => Hospital.fromMap(e)).toList();
    });
  }

  Future<void> _addHospital(String name) async {
    final db = await DatabaseHelper().db;
    await db.insert('hospitals', {'name': name});
    _loadHospitals();
  }

  Future<void> _deleteHospital(int id) async {
    final db = await DatabaseHelper().db;
    await db.delete('hospitals', where: 'id = ?', whereArgs: [id]);
    _loadHospitals();
  }

  void _showAddHospitalDialog() {
    String hospitalName = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: kBackgroundColor,
            title: const Text('Hastane Ekle', style: TextStyle(color: Colors.black)),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Hastane adı', filled: true, fillColor: Color(0xFFF5EFE6)),
              style: const TextStyle(color: Colors.black),
              onChanged: (v) {
                setState(() {
                  hospitalName = v;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal', style: TextStyle(color: kAccentColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hospitalName.trim().isEmpty ? kAddButtonColor : Color(0xFF6D94C5),
                  foregroundColor: kTextColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (hospitalName.trim().isNotEmpty) {
                    _addHospital(hospitalName.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Kaydet', style: TextStyle(color: kTextColor)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteHospitalDialog(Hospital hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hastane Sil'),
        content: Text('${hospital.name} hastanesini silmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteHospital(hospital.id!);
              Navigator.pop(context);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Center(child: Text('Hastaneler')),
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: hospitals.length + 1, // Add butonu için +1
                itemBuilder: (context, i) {
                  if (i < hospitals.length) {
                    final hospital = hospitals[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeviceListScreen(hospital: hospital),
                          ),
                        );
                      },
                      onLongPress: () => _showDeleteHospitalDialog(hospital),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: kAccentColor.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            hospital.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Son eleman: Add butonu
                    return GestureDetector(
                      onTap: _showAddHospitalDialog,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kAddButtonColor,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: kAccentColor.withOpacity(0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: kTextColor, size: 50),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
