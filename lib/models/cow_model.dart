class CowModel {
  final int? id;
  final String code;
  final String name;
  final String breed;
  final int age;
  final String status;
  final String health;
  final DateTime createdAt;

  const CowModel({
    this.id,
    required this.code,
    required this.name,
    required this.breed,
    required this.age,
    required this.status,
    required this.health,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'breed': breed,
      'age': age,
      'status': status,
      'health': health,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CowModel.fromMap(Map<String, Object?> map) {
    return CowModel(
      id: map['id'] as int?,
      code: map['code'] as String,
      name: map['name'] as String,
      breed: map['breed'] as String,
      age: map['age'] as int,
      status: map['status'] as String,
      health: map['health'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
