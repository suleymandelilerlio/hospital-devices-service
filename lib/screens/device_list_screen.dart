import 'package:flutter/material.dart';
import '../../main.dart';
import '../core/database_helper.dart';
import '../models/device.dart';
import '../models/hospital.dart';
import '../widgets/date_picker_field.dart';
const Color kBackgroundColor = Color(0xFFF5EFE6); // en açık
const Color kPrimaryColor = Color(0xFF6D94C5); // orta

const Color kAccentColor = Color(0xFF6D94C5); // daha koyu, palete uygun
const Color kButtonColor = Color(0xFFCBDCEB); // ana buton
const Color kAddButtonColor = Color(0xFFB6C2D4); // ekle butonu
const Color kTextColor = Colors.white;
class DeviceListScreen extends StatefulWidget {
  final Hospital hospital;
  const DeviceListScreen({Key? key, required this.hospital}) : super(key: key);

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<Device> devices = [];
  List<Map<String, dynamic>> demirbaslar = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _loadAssets();
  }

  Future<void> _loadDevices() async {
    final db = await DatabaseHelper().db;
    final result = await db.query('devices', where: 'hospitalId = ?', whereArgs: [widget.hospital.id]);
    setState(() {
      devices = result.map((e) => Device.fromMap(e)).toList();
    });
  }

  Future<void> _loadAssets() async {
    final assets = await DatabaseHelper().getAssets(widget.hospital.id!);
    setState(() {
      demirbaslar = assets;
    });
  }

  void _addDemirbas() {
    String demirbasName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demirbaş Ekle', style: TextStyle(color: Colors.black)),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Demirbaş adı'),

          onChanged: (v) => demirbasName = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (demirbasName.trim().isNotEmpty) {
                await DatabaseHelper().insertAsset(widget.hospital.id!, demirbasName.trim());
                Navigator.pop(context);
                _loadAssets();
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDemirbas(int id) async {
    await DatabaseHelper().deleteAsset(id);
    _loadAssets();
  }

  Future<void> _addOrUpdateDevice({Device? device}) async {
    String name = device?.name ?? '';
    String serialNo = device?.serialNo ?? '';
    String maintenanceDate = device?.maintenanceDate ?? '';
    String maintenanceStatus = device?.maintenanceStatus ?? '';
    String note = device?.note ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device == null ? 'Cihaz Ekle' : 'Cihazı Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Cihaz Adı'),
                controller: TextEditingController(text: name),
                onChanged: (v) => name = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Seri No'),
                controller: TextEditingController(text: serialNo),
                onChanged: (v) => serialNo = v,
              ),
              const SizedBox(height: 12), // Seri No ile Bakım Tarihi arasında boşluk
              DatePickerField(
                label: 'Bakım Tarihi',
                initialDate: maintenanceDate,
                onDateSelected: (date) => maintenanceDate = date,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Bakım Durumu'),
                controller: TextEditingController(text: maintenanceStatus),
                onChanged: (v) => maintenanceStatus = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Not'),
                controller: TextEditingController(text: note),
                onChanged: (v) => note = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = await DatabaseHelper().db;
              if (device == null) {
                await db.insert('devices', {
                  'hospitalId': widget.hospital.id,
                  'name': name,
                  'serialNo': serialNo,
                  'maintenanceDate': maintenanceDate,
                  'maintenanceStatus': maintenanceStatus,
                  'note': note,
                });
              } else {
                await db.update(
                  'devices',
                  {
                    'name': name,
                    'serialNo': serialNo,
                    'maintenanceDate': maintenanceDate,
                    'maintenanceStatus': maintenanceStatus,
                    'note': note,
                  },
                  where: 'id = ?',
                  whereArgs: [device.id],
                );
              }
              Navigator.pop(context);
              _loadDevices();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDevice(Device device) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cihazı Sil'),
        content: Text('${device.name} cihazını silmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = await DatabaseHelper().db;
              await db.delete('devices', where: 'id = ?', whereArgs: [device.id]);
              Navigator.pop(context);
              _loadDevices();
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
      appBar: AppBar(
        title: Text('${widget.hospital.name} Cihazları'),
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextColor,
        elevation: 0,
      ),
      backgroundColor: kBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateDevice(),
        backgroundColor: kAddButtonColor,
        child: const Icon(Icons.add, color: kTextColor),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addDemirbas,
                icon: const Icon(Icons.add),
                label: const Text('Demirbaş Ekle', style: TextStyle(color:Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  foregroundColor: kTextColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3.5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: demirbaslar.length,
              itemBuilder: (context, i) {
                final d = demirbaslar[i];
                return Chip(
                  label: Text(d['name'], style: const TextStyle(color: kTextColor)),
                  backgroundColor: kPrimaryColor,
                  deleteIcon: const Icon(Icons.close, color: Colors.white),
                  onDeleted: () => _deleteDemirbas(d['id']),
                  elevation: 2,
                  shadowColor: kAccentColor.withOpacity(0.15),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: Text('Cihaz Adı', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Seri No', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Bakım Tarihi', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Bakım Durumu', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Not', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, i) {
                final device = devices[i];
                return GestureDetector(
                  onTap: () => _addOrUpdateDevice(device: device),
                  onLongPress: () => _deleteDevice(device),
                  child: Card(
                    color: kPrimaryColor,
                    shadowColor: kAccentColor.withOpacity(0.15),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(device.name, style: const TextStyle(color: kTextColor))),
                          Expanded(child: Text(device.serialNo, style: const TextStyle(color: kTextColor))),
                          Expanded(child: Text(device.maintenanceDate, style: const TextStyle(color: kTextColor, fontSize: 12))),
                          Expanded(child: Text(device.maintenanceStatus, style: const TextStyle(color: kTextColor))),
                          Expanded(child: Text(device.note, style: const TextStyle(color: kTextColor))),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
