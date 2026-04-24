class FoodModel {
  final int? id;
  final String name;
  final double stock;
  final String unit;
  final String category;
  final DateTime purchaseDate;
  final double unitPrice;
  final double dailyConsumption;
  final String? photoPath;

  const FoodModel({
    this.id,
    required this.name,
    required this.stock,
    required this.unit,
    required this.category,
    required this.purchaseDate,
    required this.unitPrice,
    required this.dailyConsumption,
    this.photoPath,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'unit': unit,
      'category': category,
      'purchase_date': purchaseDate.toIso8601String(),
      'unit_price': unitPrice,
      'daily_consumption': dailyConsumption,
      'photo_path': photoPath,
    };
  }

  factory FoodModel.fromMap(Map<String, Object?> map) {
    return FoodModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      stock: (map['stock'] as num).toDouble(),
      unit: map['unit'] as String,
      category: map['category'] as String,
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      unitPrice: (map['unit_price'] as num).toDouble(),
      dailyConsumption: ((map['daily_consumption'] as num?) ?? 0).toDouble(),
      photoPath: map['photo_path'] as String?,
    );
  }
}
