class UserModel {
  final int? id;
  final String username;
  final String firstName;
  final String password;
  final String email;
  final String phone;
  final DateTime creationDate;
  final String address;

  const UserModel({
    this.id,
    required this.username,
    required this.firstName,
    required this.password,
    required this.email,
    required this.phone,
    required this.creationDate,
    required this.address,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'password': password,
      'email': email,
      'phone': phone,
      'creation_date': creationDate.toIso8601String(),
      'address': address,
    };
  }

  factory UserModel.fromMap(Map<String, Object?> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      firstName: map['first_name'] as String,
      password: map['password'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      creationDate: DateTime.parse(map['creation_date'] as String),
      address: map['address'] as String,
    );
  }
}
