class KiteItem {
  KiteItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.sizeMeters,
    required this.year,
    this.priceEur = '',
  });

  final String id;
  final String brand;
  final String model;
  final String sizeMeters;
  final String year;
  final String priceEur;
}

class BarItem {
  BarItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.lineLengthMeters,
    required this.widthCm,
    required this.year,
    this.priceEur = '',
  });

  final String id;
  final String brand;
  final String model;
  final String lineLengthMeters;
  final String widthCm;
  final String year;
  final String priceEur;
}

class BoardItem {
  BoardItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.type,
    required this.sizeCm,
    required this.year,
    this.priceEur = '',
  });

  final String id;
  final String brand;
  final String model;
  final String type;
  final String sizeCm;
  final String year;
  final String priceEur;
}

class HarnessItem {
  HarnessItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.size,
    required this.year,
    this.priceEur = '',
  });

  final String id;
  final String brand;
  final String model;
  final String size;
  final String year;
  final String priceEur;
}

class WetsuitItem {
  WetsuitItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.thickness,
    required this.size,
    required this.year,
    this.priceEur = '',
  });

  final String id;
  final String brand;
  final String model;
  final String thickness;
  final String size;
  final String year;
  final String priceEur;
}

class HelmetItem {
  HelmetItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.priceEur = '',
  });

  final String id;
  final String brand;
  final String model;
  final String year;
  final String priceEur;
}

class VestItem {
  VestItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.size,
    required this.year,
    this.priceEur = '',
  });

  final String id;
  final String brand;
  final String model;
  final String size;
  final String year;
  final String priceEur;
}

class GearSetup {
  GearSetup({
    required this.id,
    required this.name,
    required this.kiteId,
    this.barId,
    required this.boardId,
    this.harnessId,
    this.wetsuitId,
    this.helmetId,
    this.vestId,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String kiteId;
  final String? barId;
  final String boardId;
  final String? harnessId;
  final String? wetsuitId;
  final String? helmetId;
  final String? vestId;
  final DateTime createdAt;

  GearSetup copyWith({
    String? id,
    String? name,
    String? kiteId,
    Object? barId = _unset,
    String? boardId,
    Object? harnessId = _unset,
    Object? wetsuitId = _unset,
    Object? helmetId = _unset,
    Object? vestId = _unset,
    DateTime? createdAt,
  }) {
    return GearSetup(
      id: id ?? this.id,
      name: name ?? this.name,
      kiteId: kiteId ?? this.kiteId,
      barId: barId == _unset ? this.barId : barId as String?,
      boardId: boardId ?? this.boardId,
      harnessId: harnessId == _unset ? this.harnessId : harnessId as String?,
      wetsuitId: wetsuitId == _unset ? this.wetsuitId : wetsuitId as String?,
      helmetId: helmetId == _unset ? this.helmetId : helmetId as String?,
      vestId: vestId == _unset ? this.vestId : vestId as String?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const Object _unset = Object();
}
