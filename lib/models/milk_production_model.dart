class MilkProductionModel {
  final int? id;
  final double quantity;
  final DateTime productionDate;
  final String moment;

  const MilkProductionModel({
    this.id,
    required this.quantity,
    required this.productionDate,
    required this.moment,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'production_date': productionDate.toIso8601String(),
      'moment': moment,
    };
  }

  factory MilkProductionModel.fromMap(Map<String, Object?> map) {
    return MilkProductionModel(
      id: map['id'] as int?,
      quantity: (map['quantity'] as num).toDouble(),
      productionDate: DateTime.parse(map['production_date'] as String),
      moment: map['moment'] as String,
    );
  }
}
