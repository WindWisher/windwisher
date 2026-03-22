class LinkedDevice {
  const LinkedDevice({
    required this.id,
    required this.name,
    required this.kind,
    required this.status,
    required this.lastSync,
  });

  final String id;
  final String name;
  final String kind;
  final String status;
  final String lastSync;

  LinkedDevice copyWith({String? name, String? status}) {
    return LinkedDevice(
      id: id,
      name: name ?? this.name,
      kind: kind,
      status: status ?? this.status,
      lastSync: lastSync,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'kind': kind,
      'status': status,
      'lastSync': lastSync,
    };
  }

  static LinkedDevice fromJson(Map<String, dynamic> json) {
    return LinkedDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Dispositivo',
      kind: json['kind'] as String? ?? 'Dispositivo Android',
      status: json['status'] as String? ?? 'Pendiente',
      lastSync: json['lastSync'] as String? ?? 'sin sincronizacion',
    );
  }
}
