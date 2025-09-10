class Device {
  final int? id;
  final int hospitalId;
  final String name;
  final String serialNo;
  final String maintenanceDate;
  final String maintenanceStatus;
  final String note;

  Device({
    this.id,
    required this.hospitalId,
    required this.name,
    required this.serialNo,
    required this.maintenanceDate,
    required this.maintenanceStatus,
    required this.note,
  });

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'],
      hospitalId: map['hospitalId'],
      name: map['name'],
      serialNo: map['serialNo'],
      maintenanceDate: map['maintenanceDate'],
      maintenanceStatus: map['maintenanceStatus'],
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hospitalId': hospitalId,
      'name': name,
      'serialNo': serialNo,
      'maintenanceDate': maintenanceDate,
      'maintenanceStatus': maintenanceStatus,
      'note': note,
    };
  }
}

