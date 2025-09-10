class Hospital {
  final int? id;
  final String name;

  Hospital({this.id, required this.name});

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      id: map['id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

